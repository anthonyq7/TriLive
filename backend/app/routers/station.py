from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
import os

from ..database import SessionLocal, Stop as StationModel
from ..models import Station

router = APIRouter()
TRIMET_APP_ID = os.getenv("TRIMET_APP_ID")

# Dependency to get a DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/stations", response_model=List[Station])
async def list_stations(db: Session = Depends(get_db)):
    db_stops = db.query(StationModel).all()
    return [
        Station(
            stop_id=s.id,
            name=s.name,
            dir="",       
            lon=s.lon,
            lat=s.lat,
            dist=0
        )
        for s in db_stops
    ]

@router.get("/stations/{stop_id}", response_model=Station)
async def get_station(stop_id: int, db: Session = Depends(get_db)):
    s = db.get(StationModel, stop_id)
    if not s:
        raise HTTPException(404, "Station not found")
    return Station(stop_id=s.id, name=s.name, dir="", lon=s.lon, lat=s.lat, dist=0)

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

@router.delete("/stations/{stop_id}")
async def delete_station(stop_id: int, db: Session = Depends(get_db)):
    s = db.get(StationModel, stop_id)
    if not s:
        raise HTTPException(404, "Station not found")
    db.delete(s)
    db.commit()
    return {"message": "Station deleted"}
