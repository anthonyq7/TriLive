import os
import json
import traceback
import asyncio
from typing import List

import httpx
from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlalchemy.orm import Session

from backend.app.db.database import SessionLocal
from backend.app.models.station import StationModel
from backend.app.schemas.station import Station, Arrival
from backend.app.utils.trimet import (
    fetch_and_load_stations,
    fetch_arrivals,
    TRIMET_STOPS_URL
)

router = APIRouter()
TRIMET_KEY = os.getenv("TRIMET_API_KEY")


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/stations/import", tags=["admin"])
async def import_stations(
    request: Request,
    db: Session = Depends(get_db),
    bbox: str | None = Query(None),
):
    # clear old cache
    request.app.state.arrivals_cache.clear()

    # load all stops into the DB (run blocking IO in a thread)
    count = await asyncio.to_thread(fetch_and_load_stations, db, bbox)

    # correctly pull just the integer IDs
    stops = [sid for (sid,) in db.query(StationModel.id).all()]

    # now kick off arrivals fetches
    coros = [fetch_arrivals(sid) for sid in stops]
    await asyncio.gather(*coros)

    return {"imported": count}


@router.get("/stations/near", response_model=List[Station], tags=["stations"])
async def get_nearby_stations(
    lat: float = Query(..., description="Latitude of center point"),
    lng: float = Query(..., description="Longitude of center point"),
    meters: int = Query(2000, description="Search radius in meters"),
):
    """
    Fetch live stops near a point from TriMet.
    """
    if not TRIMET_KEY:
        raise HTTPException(500, detail="TRIMET_API_KEY not configured")

    params = {
        "appID":  TRIMET_KEY,
        "ll":     f"{lat},{lng}",
        "meters": meters,
        "json":   "true",
    }
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(TRIMET_STOPS_URL, params=params)
        resp.raise_for_status()

    locations = resp.json().get("resultSet", {}).get("location", [])
    return [
        Station(
            id          = loc["locid"],
            name        = loc["desc"],
            latitude    = loc["lat"],
            longitude   = loc["lng"],
            description = loc.get("desc2"),
        )
        for loc in locations
    ]


@router.get("/stations", response_model=List[Station], tags=["stations"])
async def list_stations(request: Request, db: Session = Depends(get_db)):
    """
    Return all stations from your database (with 60s Redis caching).
    """
    redis = request.app.state.redis
    cached = await redis.get("stations")
    if cached:
        return json.loads(cached)

    records = db.query(StationModel).all()
    result = [
        Station.model_validate({
            "id":          s.id,
            "name":        s.name,
            "latitude":    s.latitude,
            "longitude":   s.longitude,
            "description": s.description,
        })
        for s in records
    ]
    await redis.set("stations", json.dumps([r.model_dump() for r in result]), ex=60)
    return result


@router.get("/stations/{id}", response_model=Station, tags=["stations"])
async def get_station(id: int, db: Session = Depends(get_db)):
    """
    Fetch one station by its ID.
    """
    s = db.query(StationModel).filter(StationModel.id == id).first()
    if not s:
        raise HTTPException(404, "Station not found")
    return Station.model_validate(s.__dict__)


@router.put("/stations/{id}", response_model=Station, tags=["stations"])
async def update_station(
    request: Request,
    id: int,
    updated: Station,
    db: Session = Depends(get_db),
):
    """
    Update an existing station.
    """
    db_s = db.query(StationModel).filter(StationModel.id == id).first()
    if not db_s:
        raise HTTPException(404, "Station not found")

    for key, value in updated.model_dump().items():
        setattr(db_s, key, value)
    db.commit()
    await request.app.state.redis.delete("stations")
    db.refresh(db_s)
    return Station.model_validate(db_s.__dict__)


@router.delete("/stations/{id}", tags=["stations"])
async def delete_station(request: Request, id: int, db: Session = Depends(get_db)):
    """
    Delete a station by its ID.
    """
    db_s = db.query(StationModel).filter(StationModel.id == id).first()
    if not db_s:
        raise HTTPException(404, "Station not found")
    db.delete(db_s)
    db.commit()
    await request.app.state.redis.delete("stations")
    return {"deleted": id}


@router.get(
    "/stations/{id}/arrivals",
    response_model=List[Arrival],
    summary="Real-time arrivals at a station (cached, refreshed in background)",
    tags=["stations"],
)
async def get_arrivals(request: Request, id: int, limit: int = Query(5, description="Max arrivals")):
    """
    Return the latest cached arrivals for a stop.
    """
    if not TRIMET_KEY:
        raise HTTPException(500, "TRIMET_API_KEY not set")

    cache: dict[int, list] = request.app.state.arrivals_cache
    raw = cache.get(id)
    if raw is None:
        # Cache still warming up
        raise HTTPException(503, "Arrivals cache warming up, retry shortly")

    validated = [Arrival.model_validate(a) for a in raw]
    return validated[:limit]


@router.get("/ping", tags=["health"])
async def ping():
    return {"pong": True}
