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


_arrivals_cache: Dict[int, List[dict]] = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # set up Redis
    redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
    app.state.redis = await redis.from_url(redis_url, decode_responses=True)

    # bind our annotated module‐level cache
    app.state.arrivals_cache = _arrivals_cache

    yield

    await app.state.redis.close()


app = FastAPI(lifespan=lifespan, debug=True)

@app.get("/ping")
async def ping():
    return {"pong": True}


async def refresh_arrivals_loop(interval_s: int = 60):
    while True:
        db: Session = SessionLocal()
        try:
            # load all station IDs
            stops = db.query(StationModel.id).all() 

            # fetch each stop’s arrivals in parallel
            coros = [fetch_arrivals(sid) for (sid,) in stops]
            results = await asyncio.gather(*coros, return_exceptions=True)

            # update our in‐memory cache
            for (sid,), res in zip(stops, results):
                if isinstance(res, Exception):
                    # you could log here
                    continue
                _arrivals_cache[sid] = res

        finally:
            db.close()

        await asyncio.sleep(interval_s)

@app.on_event("startup")
async def on_startup():
    # ensure DB tables are created
    Base.metadata.create_all(bind=engine)

    # start the background refresh task (don’t await it)
    asyncio.create_task(refresh_arrivals_loop(60))

app.include_router(station.router)
