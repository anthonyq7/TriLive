# main.py
import os
import asyncio
import json
from typing import Dict, List
from contextlib import asynccontextmanager

from fastapi import FastAPI
import redis.asyncio as redis
from sqlalchemy.orm import Session

from backend.app.db.database import Base, engine, SessionLocal
from backend.app.models.station import StationModel
from backend.app.routers import station
from backend.app.utils.trimet import fetch_arrivals

# in-memory cache for arrivals
_arrivals_cache: Dict[int, List[dict]] = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1) Connect to your Redis (using REDIS_URL from Render)
    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
    app.state.redis = await redis.from_url(redis_url, decode_responses=True)

    # 2) Wire up our in-memory arrivals cache
    app.state.arrivals_cache = _arrivals_cache

    # 3) Ensure your database tables exist
    Base.metadata.create_all(bind=engine)

    # 4) Kick off the background refresher (don’t await—let it run on its own)
    asyncio.create_task(refresh_arrivals_loop(30))

    yield  # <-- everything above runs at startup

    await app.state.redis.close()


async def refresh_arrivals_loop(interval_s: int = 60):
    """
    Every `interval_s` seconds, re-fetch arrivals for
    every station in your DB and store them in app.state.arrivals_cache.
    """
    # initial delay so we don’t block startup
    await asyncio.sleep(interval_s)

    while True:
        # open a new DB session
        db: Session = SessionLocal()
        try:
            # grab all station IDs
            stops = [sid for (sid,) in db.query(StationModel.id).all()]

            # kick off all arrival‐fetches in parallel
            coros = [fetch_arrivals(sid) for sid in stops]
            results = await asyncio.gather(*coros, return_exceptions=True)

            # stash successful results into the in‐memory cache
            for (sid,), res in zip(stops, results):
                if not isinstance(res, Exception):
                    app.state.arrivals_cache[sid] = res

        finally:
            db.close()

        # wait before the next cycle
        await asyncio.sleep(interval_s)

# Attach our lifespan handler
app = FastAPI(lifespan=lifespan, debug=True)

@app.get("/ping")
async def ping():
    return {"pong": True}

# mount your router exactly as before
app.include_router(station.router)