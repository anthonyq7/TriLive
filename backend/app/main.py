# main.py

import os
import asyncio
from typing import Dict, List
from contextlib import asynccontextmanager

from fastapi import FastAPI
import redis.asyncio as redis
from sqlalchemy.orm import Session

from backend.app.db.database import Base, engine, SessionLocal
from backend.app.models.station import StationModel
from backend.app.routers import station
from backend.app.utils.trimet import fetch_arrivals

# a simple in-memory cache; we'll attach it to app.state
_arrivals_cache: Dict[int, List[dict]] = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 1) start Redis
    redis_url = os.getenv("REDIS_URL")
    if not redis_url:
        raise RuntimeError("REDIS_URL must be set")
    app.state.redis = await redis.from_url(redis_url, decode_responses=True)

    # 2) attach our in-memory cache
    app.state.arrivals_cache = _arrivals_cache

    # 3) ensure database tables exist
    Base.metadata.create_all(bind=engine)

    # 4) kick off our background refresher
    bg_task = asyncio.create_task(_refresh_arrivals_loop(60, app))

    try:
        yield  # <-- everything above this is “startup”
    finally:
        # shutdown: cancel bg task and close Redis
        bg_task.cancel()
        await app.state.redis.close()


app = FastAPI(lifespan=lifespan, debug=True)

@app.get("/ping")
async def ping():
    return {"pong": True}


async def _refresh_arrivals_loop(interval_s: int, app: FastAPI):
    """
    Every `interval_s` seconds, re‐fetch arrivals for
    every station in your DB and store in app.state.arrivals_cache.
    """
    while True:
        db: Session = SessionLocal()
        try:
            # pull all station IDs
            stops = db.query(StationModel.id).all()  # returns [(id1,), (id2,), …]

            # fire off all fetches in parallel
            coros = [fetch_arrivals(sid) for (sid,) in stops]
            results = await asyncio.gather(*coros, return_exceptions=True)

            # write successes into our cache
            for (sid,), res in zip(stops, results):
                if isinstance(res, Exception):
                    # you could log this exception…
                    continue
                app.state.arrivals_cache[sid] = res

        finally:
            db.close()

        await asyncio.sleep(interval_s)


# mount your other routes as before
app.include_router(station.router)
