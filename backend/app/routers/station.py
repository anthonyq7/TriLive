from fastapi import APIRouter, HTTPException, Depends, Request, Query
from sqlalchemy.orm import Session
from typing import List
import os

from ..database import SessionLocal, Stop as StationModel
from ..models import Station
from ..utils.overpass import parse_overpass
from ..clients import redis_client
from ..database import Stop

router = APIRouter()
# Trimet API credentials, if used for external data sources
TRIMET_APP_ID = os.getenv("TRIMET_APP_ID")

# Dependency to get a DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

"""
Lists all stations in the database.
Returns a list of Station Pydantic models.
"""
@router.get("/stations", response_model=List[Station])
async def list_stations(db: Session = Depends(get_db)):
    db_stops = db.query(StationModel).all()
    return [
        Station(
            stop_id=s.id,
            name=s.name,
            dir=s.dir,       
            lon=s.longitude,
            lat=s.latitude,
            dist=0
        )
        for s in db_stops
    ]


"""
Gets a single station by its ID.
Raises 404 if not found.
"""
@router.get("/stations/{stop_id}", response_model=Station)
async def get_station(stop_id: int, db: Session = Depends(get_db)):
    s = db.get(StationModel, stop_id)
    if not s:
        raise HTTPException(404, "Station not found")
    return Station(stop_id=s.id, name=s.name, dir="", lon=s.lon, lat=s.lat, dist=0)


"""
Creates a new station record from the provided Station model.
Commits to the database and returns the created record.
"""
@router.post("/stations", response_model=Station)
async def create_station(station: Station, db: Session = Depends(get_db)):
    new = StationModel(id=station.stop_id, name=station.name, lat=station.lat, lon=station.lon)
    db.add(new)
    db.commit()
    db.refresh(new)
    return Station(
        stop_id=new.id,
        name=new.name,
        dir="", lon=new.lon, lat=new.lat, dist=0
    )


"""
Updates an existing station's name (and other mutable fields if needed).
Raises 404 if the station doesn't exist.
"""
@router.put("/stations/{stop_id}", response_model=Station)
async def update_station(stop_id: int, station: Station, db: Session = Depends(get_db)):
    s = db.get(StationModel, stop_id)
    if not s:
        raise HTTPException(404, "Station not found")
    s.name = station.name
    db.commit()
    db.refresh(s)
    return Station(
        stop_id=s.id,
        name=s.name,
        dir="", lon=s.lon, lat=s.lat, dist=0
    )


"""
Delete a station record by ID.
Raises 404 if the station doesn't exist.
"""
@router.delete("/stations/{stop_id}")
async def delete_station(stop_id: int, db: Session = Depends(get_db)):
    s = db.get(StationModel, stop_id)
    if not s:
        raise HTTPException(404, "Station not found")
    db.delete(s)
    db.commit()
    return {"message": "Station deleted"}



"""
Admin endpoint to bulk import stations from the Overpass API.
- Clears Redis cache for stations.
- Validates the bounding box parameter.
- Wipes existing station data.
- Fetches fresh station data from Overpass.
- Inserts the new stations.
"""
@router.post("/stations/import", tags=["admin"])
async def import_stations(
    request: Request,
    bbox: str = Query(..., description="min_lon,min_lat,max_lon,max_lat"),
    db: Session = Depends(get_db),
):
    # clear cache
    redis_client.delete("stations")

    # validate bbox
    try:
        coords = [float(x) for x in bbox.split(",")]
        if len(coords) != 4:
            raise ValueError
    except ValueError:
        raise HTTPException(400, "Invalid bbox; use min_lon,min_lat,max_lon,max_lat")

    # wipe old data
    db.query(StationModel).delete()
    db.commit()

    # fetch fresh from Overpass
    try:
        stations = await parse_overpass(coords)
    except Exception as e:
        raise HTTPException(502, f"Overpass error: {e}")

    # insert new ones
    for s in stations:
        db.add(StationModel(**s))
    db.commit()

    return {"imported": len(stations)}


