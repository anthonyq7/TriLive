from fastapi import APIRouter, Request, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import json
import os
import httpx
from fastapi import Query
import traceback

from backend.app.db.database import SessionLocal
from backend.app.models.station import StationModel
from backend.app.schemas.station import Station
from backend.app.utils.overpass import parse_overpass

router = APIRouter()
TRIMET_KEY     = os.getenv("TRIMET_API_KEY")
TRIMET_V2_URL  = "https://developer.trimet.org/ws/v2/stops"

@router.get(
    "/stations/near",
    response_model=List[Station],
    summary="Fetches live stops near a point from TriMet",
)
async def get_nearby_stations(
    lat: float = Query(..., description="Latitude of center point"),
    lng: float = Query(..., description="Longitude of center point"),
    meters: int = Query(2000, description="Search radius in meters"),
):
    if not TRIMET_KEY:
        raise HTTPException(500, detail="TRIMET_API_KEY not configured")
    params = {
        "appID": TRIMET_KEY,
        "ll": f"{lat},{lng}",
        "meters": meters,
        "json": "true",
    }
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(TRIMET_V2_URL, params=params)
    try:
        resp.raise_for_status()
    except httpx.HTTPStatusError as e:
        raise HTTPException(e.response.status_code, detail=str(e))

    locations = resp.json().get("resultSet", {}).get("location", [])
    #maps the TriMet fields into your Pydantic Station schema
    return [
        Station(
            id=loc["locid"],
            name=loc["desc"],
            latitude=loc["lat"],
            longitude=loc["lng"],
            description=loc.get("desc2"),
        )
        for loc in locations
    ]

#this is a dependency that gives you a database session in each request
#it opens a session, tells fastapi to put it into the route and them closes when the request is done
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

#for now this is the fake database of stations, we will use postsqrsql to populate an actual database with the stations
#stations = []

@router.post("/stations/import", tags=["admin"])
async def import_stations(
    request: Request,
    bbox: str | None = Query(None, description="min_lon,min_lat,max_lon,max_lat"),
    db: Session = Depends(get_db),
):
    await request.app.state.redis.delete("stations")

    if not bbox:
        raise HTTPException(400, "bbox is required")

    try:
        coords = [float(x) for x in bbox.split(",")]
        if len(coords) != 4:
            raise ValueError
    except ValueError:
        raise HTTPException(400, "Invalid bbox format; use min_lon,min_lat,max_lon,max_lat")

    count = 0
    for station in parse_overpass(coords):
        # convert Pydantic -> SQLModel
        db.add(StationModel(**station.model_dump()))
        count += 1

    db.commit()
    return {"imported": count}

@router.get("/stations/{id}/arrivals", summary="Real-time arrivals at a station")
async def get_arrivals(id: int, limit: int = 5):
    if not TRIMET_KEY:
        raise HTTPException(500, "TRIMET_API_KEY not set")
    url = "https://developer.trimet.org/ws/v2/arrivals"
    params = {"appID": TRIMET_KEY, "locIDs": id, "json": "true", "count": limit}
    async with httpx.AsyncClient() as client:
        resp = await client.get(url, params=params)
    try:
        resp.raise_for_status()
    except httpx.HTTPStatusError as e:
        raise HTTPException(e.response.status_code, str(e))
    arrivals = resp.json().get("resultSet", {}).get("arrival", [])
    #maps to sql
    return [
        {
            "route": a["route"],
            "scheduled": a["scheduled"],
            "estimated": a.get("estimated"),
            "vehicle": a.get("vehicleID")
        }
        for a in arrivals
    ]

#this creates the station endpoints
@router.post("/stations", response_model=Station)
async def create_station(request: Request, station: Station, db: Session = Depends(get_db)):
    #this converts the incoming pydantic station into a sqlalchemy model
    db_station = StationModel(**station.dict())


    #adds it to the db station
    db.add(db_station)
    db.commit()
    db.refresh(db_station)


    await request.app.state.redis.delete("stations")
    return db_station




@router.get("/stations", response_model=List[Station])
async def get_stations(request: Request, db: Session = Depends(get_db)):
    redis = request.app.state.redis
    #checks cache if its in there it just uses that
    cached = await redis.get("stations")
    if cached:
        return json.loads(cached)
    


    #it queries all the station rows and returns them
    stations = db.query(StationModel).all()
    result = []
    for s in stations:
        result.append( Station.model_validate({
            "id":          s.id,
            "name":        s.name,
            "latitude":    s.latitude,
            "longitude":   s.longitude,
            "description": s.description,
        }) )
    
    #caches results for 60 seconds/ periodic updates
    await redis.set("stations", json.dumps([s.model_dump() for s in result]), ex=60)


    return result


#gets a specific station by the station id
@router.get("/stations/{id}", response_model=Station)
async def get_station(id: int, db: Session = Depends(get_db)):
    station = db.query(StationModel).filter(StationModel.id == id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
    return station



@router.put("/stations/{id}", response_model=Station)
async def update_station(request: Request, id: int, updated: Station, db: Session = Depends(get_db)):
    station = db.query(StationModel).filter(StationModel.id == id).first()


    if not station:
        raise HTTPException(status_code=404, detail="Station not found")


    #overwrite the values of the current station and updates the values
    for key, value in updated.model_dump().items():
        setattr(station, key, value)


    db.commit()
    await request.app.state.redis.delete("stations")
    db.refresh(station)

    return station



#deletes a station basically removing it from the database
@router.delete("/stations/{id}")
async def delete_station(request: Request, id: int, db: Session = Depends(get_db)):
    station = db.query(StationModel).filter(StationModel.id == id).first()
    if not station:
        raise HTTPException(status_code=404, detail="Station not found")
    db.delete(station)
    db.commit()
    await request.app.state.redis.delete("stations")
    return {"message": "Station deleted"}

@router.get("/ping")
async def ping():
    return {"pong": True}