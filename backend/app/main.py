from fastapi import FastAPI
from redis.asyncio import Redis # type: ignore
from pydantic import BaseModel
from typing import Optional

from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session # type: ignore
from typing import List

from database import SessionLocal, engine
from models import StationModel
from schemas import Station

import models
import os, json

app = FastAPI()
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")

#creates the tables defined in models.py
models.Base.metadata.create_all(bind=engine)

#this is a dependency that gives you a database session in each request
#it opens a session, tells fastapi to put it into the route and them closes when the request is done
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


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
@app.post("/stations", response_model=Station)
def create_station(station: Station, db: Session = Depends(get_db)):

    #this converts the incoming pydantic station into a sqlalchemy model
    db_station = StationModel(**station.dict())

    #adds it to the db station
    db.add(db_station)
    db.commit()
    db.refresh(db_station)

    return db_station




#gets all stations
@app.get("/stations", response_model=List[Station])
def get_stations(db: Session = Depends(get_db)):

    #it queries all the station rows and returns them
    return db.query(StationModel).all()

#gets a specific station by the station id
@app.get("/stations/{id}", response_model=Station)
def get_station(id: int, db: Session = Depends(get_db)):
    station = db.query(StationModel).filter(StationModel.id == id).first()

    if not station:
        raise HTTPException(status_code=404, detail="Station not found")

    return station


#updates a specific station by the station id
@app.put("/stations/{id}", response_model=Station)
def update_station(id: int, updated: Station, db: Session = Depends(get_db)):
    station = db.query(StationModel).filter(StationModel.id == id).first()

    if not station:
        raise HTTPException(status_code=404, detail="Station not found")

    #overwrite the values of the current station and updates the values
    for key, value in updated.model_dump().items():
        setattr(station, key, value)

    db.commit()
    db.refresh(station)
    return station





#deletes a station basically removing it from the results
@app.delete("/stations/{id}")
def delete_station(id: int, db: Session = Depends(get_db)):
    station = db.query(StationModel).filter(StationModel.id == id).first()

    if not station:
        raise HTTPException(status_code=404, detail="Station not found")

    db.delete(station)
    db.commit()

    return {"message": "Station deleted"}

