from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from dotenv import load_dotenv
from contextlib import asynccontextmanager

import os
import datetime
import json
import asyncio
import zoneinfo

import httpx
import redis

# now import your modules _inside_ the app package:
from . import models, database
from .scheduler import scheduler

#track request, and check if favorite can be tracked
load_dotenv()
@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler.add_job(sync_stop_table, trigger="cron", day=1, hour=0, minute=0, misfire_grace_time=3600, coalesce=True, id="monthly_stop_sync")
    scheduler.start()
    yield
    scheduler.shutdown()

app = FastAPI(lifespan=lifespan)
TRIMET_APP_ID=os.getenv("TRIMET_APP_ID")
if not TRIMET_APP_ID:
    raise RuntimeError("TRIMET_APP_ID is not set!")

client = httpx.AsyncClient()
#database.Base.metadata.drop_all(bind=database.engine)
database.Base.metadata.create_all(bind=database.engine)
REDIS_URL=os.getenv("REDIS_URL")
redis_client = redis.from_url(REDIS_URL)

longitude= -122.6765
latitude = 45.5231

@app.get("/ping")
async def ping():
    return {"status": "ok"}

@app.get("/")
async def root():
    return {"message" : "Welcome to TriLive!"}

#returns arrivals follwing the route pyndantic models
@app.get("/arrivals/{stop_id}")
async def get_arrivals(stop_id: int):
    url = f"https://developer.trimet.org/ws/v2/arrivals?locIDs={stop_id}&showPosition=true&appID={TRIMET_APP_ID}&showPosition=true&minutes=60"
    cache_key = f"stop:{stop_id}:arrivals"
    cached_data = redis_client.get(cache_key)
    
    if cached_data:
        data_json = cached_data.decode('utf-8')
        return json.loads(data_json)

    try:
        response = await client.get(url)
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    arrivals_db = {}

    for arrival in data.get("resultSet", {}).get("arrival", []):
        status = arrival.get("status", "") 
        if status in ["estimated", "scheduled"]: #checks to make sure route will occur (not delayed or cancelled)
            eta = arrival.get("estimated") or arrival.get("scheduled")
            converted_eta = timeConvert(eta) #converts from unix ms to HR:MIN AM or PM
            new_route = models.Route(
                stop_id=stop_id,
                route_id=arrival.get("route"),
                route_name=arrival.get("fullSign") or arrival.get("shortSign") or "",
                status=status,
                eta=converted_eta,
                routeColor=arrival.get("routeColor", "")
            )
            arrivals_db[str(new_route.route_id) + ":" + str(eta)] = new_route.model_dump()
    
    redis_client.setex(cache_key, 60, json.dumps(arrivals_db))    
    return arrivals_db # -> {k:v.dict() for k, v in arrivals_db.items()}

@app.get("/stops")
async def get_stops():
    db = database.SessionLocal()
    try:
        toReturn = db.query(database.Stop).all()
        return toReturn
    finally:
        db.close()
    
@app.get("/stops/closest/{latitude}/{longitude}", response_model=models.Station) #gets closest stop
async def get_closest_stop(longitude: float, latitude: float):
    radius = 4800 #radius of 4.8 km or roughly 3 miles
    url = f"https://developer.trimet.org/ws/V2/stops?appID={TRIMET_APP_ID}&ll={longitude},{latitude}&meters={radius}&maxStops=1&json=true"

    try:
        response = await client.get(url)
        response.raise_for_status()
        data  = response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    try:
        stop = data.get("resultSet", {}).get("location", [])[0]
        stop_id = stop.get("locid", -1)
        dir = stop.get("dir", "")
        new_station = models.Station(
            stop_id=stop_id,
            name=stop.get("desc", ""),
            dir=dir,
            lon=stop.get("lng", -1.0),
            lat=stop.get("lat", -1.0),
            dist=stop.get("metersDistance", 10000)
        )
        return new_station
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
    
def timeConvert(ms_timestamp: int):
    # Convert milliseconds to seconds for fromtimestamp()
    pacific = zoneinfo.ZoneInfo("America/Los_Angeles")
    dt = datetime.datetime.fromtimestamp(ms_timestamp / 1000, tz=pacific)
    # %-I is hour without leading zero (on Unix); %M is minutes; %p is AM/PM
    return dt.strftime("%-I:%M %p")

async def fetch_stops():
    url = f"https://developer.trimet.org/ws/V1/stops?appID={TRIMET_APP_ID}&bbox=-122.836,45.387,-122.471,45.608&json=true"

    try:
        response = await client.get(url)
        response.raise_for_status()
        data = response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    stops_db = []

    for stop in data.get("resultSet", {}).get("location", []):
        stop_id = stop.get("locid", -1)
        dir = stop.get("dir", "")
        new_station = models.Station(
            stop_id=stop_id,
            name=stop.get("desc", ""),
            dir=dir,
            lon=stop.get("lng", -1.0),
            lat=stop.get("lat", -1.0),
            dist=stop.get("metersDistance", 10000)
        )

        stops_db.append(new_station)

    
    return stops_db 

async def sync_stop_table():
    stops = await fetch_stops()
    current_ids = {s.stop_id for s in stops}
    db = database.SessionLocal()
    try:
        for stop in stops:
            entry = db.query(database.Stop).filter(database.Stop.id == stop.stop_id).first()
            if not entry:
                new_entry = database.Stop(
                    id=stop.stop_id,
                    name=stop.name,
                    lat=stop.lat,
                    lon=stop.lon
                )
                db.add(new_entry)
        
        if current_ids:
            db.query(database.Stop).filter(~database.Stop.id.in_(current_ids)).delete(synchronize_session=False)
        
        db.commit()
    finally:
        db.close()


@app.put("/sync_stops")
async def sync_stops():
    try:
        await sync_stop_table()
        return {"message": "Stops successfully synced"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/track/{stop_id}/{route_id}")
async def track(ws: WebSocket, stop_id: int, route_id: int):
    await ws.accept()

    url = f"https://developer.trimet.org/ws/v2/arrivals?locIDs={stop_id}&showPosition=true&appID={TRIMET_APP_ID}&minutes=60"
    
    try:
        resp = await client.get(url)
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        await ws.close()
        raise HTTPException(status_code=500, detail=str(e))

    arrival = next(
        (a for a in data.get("resultSet", {}).get("blockPosition", [])
        if a.get("routeNumber") == route_id),
        None
    )

    if not arrival:
        await ws.send_json({"error": "route not available within the next hour"})
        await ws.close()
        return

    try:
        while True:
            resp = await client.get(url)
            resp.raise_for_status()
            data = resp.json()

            arrival = next(
                (a for a in data.get("resultSet", {}).get("blockPosition", [])
                if a.get("routeNumber") == route_id),
                None
            )

            if not arrival:
                await ws.send_json({"error": "route lost"})
                break

            feet = arrival.get("feet", 0)
            await ws.send_json({"distance": feet})

            if feet <= 10:
                await ws.send_json({"message: arrived"})
                break

            await asyncio.sleep(30)

    except WebSocketDisconnect:
        pass
    finally:
        await ws.close()



"""
@app.get("/stops")
async def get_stops():
    url = f"https://developer.trimet.org/ws/V1/stops?appID={TRIMET_APP_ID}&bbox=-122.836,45.387,-122.471,45.608&json=true"

    try:
        response = await client.get(url)
        response.raise_for_status()
        data  = response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    stops_db = {}

    for stop in data.get("resultSet", {}).get("location", []):
        stop_id = stop.get("locid", -1)
        dir = stop.get("dir", "")
        new_station = models.Station(
            stop_id=stop_id,
            name=stop.get("desc", ""),
            dir=dir,
            long=stop.get("lng", -1.0),
            lat=stop.get("lat", -1.0),
            dist=stop.get("metersDistance", 10000)
        )

        stops_db[str(stop_id) + ":" + dir] = new_station.model_dump()

    
    return stops_db 

@app.post("/favorites")
async def post_favorites(stop_id: int, route_id: int, route_name: str):
    db = database.SessionLocal()
    fav_entry = db.query(database.Favorite).filter(database.Favorite.stop_id == stop_id, database.Favorite.route_id == route_id).first()
    if not fav_entry:
        new_fav = database.Favorite(stop_id=stop_id, route_id=route_id, route_name=route_name)
        db.add(new_fav)
        db.commit()
    db.close()

@app.get("/favorites")
async def get_favorites():
    db = database.SessionLocal()
    try:
        toReturn = db.query(database.Favorite).all()
        return toReturn
    finally:
        db.close()
    """