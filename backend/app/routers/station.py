from fastapi import APIRouter, Request, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import json

from backend.app.db.database import SessionLocal
from backend.app.models.station import StationModel
from backend.app.schemas.station import Station

router = APIRouter()

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
    result = [Station.model_validate(s) for s in stations]
    
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
