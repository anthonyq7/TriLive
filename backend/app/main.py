from fastapi import FastAPI
from redis.asyncio import Redis # type: ignore
from pydantic import BaseModel
from typing import Optional
import os, json

app = FastAPI()
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")

@app.on_event("startup")
async def open_redis():
    app.state.redis = Redis.from_url(REDIS_URL, decode_responses=True)

@app.on_event("shutdown")
async def close_redis():
    await app.state.redis.close()

#used this for a test so basically FastAPI creates a route at /ping
#When a client hits /ping with a GET request:
#FastAPI calls your ping() function
#The function returns a dictionary
#FastAPI automatically converts it to JSON using Pydantic + Starlette
@app.get("/ping")
async def ping():
    return {"pong": True}

#defining classes for the stations
#we will use the coordinates to match the closest stations to the user's coordinates that we fetch using mapkit i think?
class Station(BaseModel):
    id: int
    name: str
    latitude: float
    longitude: float
    description: Optional[str] = None

#for now this is the fake database of stations, we will use postsqrsql to populate an actual database with the stations
stations = []

#this creates the station endpoints
@app.post("/stations")
async def create_station(station: Station):
    stations.append(station)
    return station

#gets all stations
@app.get("/stations")
async def get_stations():
    return stations

#gets a specific station by the station id
@app.put("/stations/{id}")
async def update_station(id: int, updated_station: Station):
    for i, station in enumerate(stations):
        if station.id == id:
            stations[i] = updated_station
            return updated_station
    raise HTTPException(status_code=404, detail="Station not found")

#deletes a station basically removing it from the results
@app.delete("/stations/{id}")
async def delete_station(id: int):
    for i, station in enumerate(stations):
        if station.id == id:
            deleted = stations.pop(i)
            return {"message": "Station deleted", "station": deleted}
    raise HTTPException(status_code=404, detail="Station not found")

