import os
import asyncio
from fastapi import FastAPI
from contextlib import asynccontextmanager
import redis.asyncio as redis
from sqlalchemy.orm import Session
from backend.app.db.database import Base, engine, SessionLocal
from backend.app.models.station import StationModel
from backend.app.routers.station import router as station_router
from backend.app.utils.trimet import fetch_arrivals

@asynccontextmanager
async def lifespan(app: FastAPI):
    redis_url = os.getenv("REDIS_URL")
    if not redis_url:
        raise RuntimeError("REDIS_URL must be set in the environment")
    app.state.redis = await redis.from_url(redis_url, decode_responses=True)

    app.state.arrivals_cache: dict[int, list[dict]] = {} # type: ignore

    async def refresh_arrivals_loop(interval_s: int = 60):
        while True:
            db: Session = SessionLocal()
            try:
                # fetch every stop ID from your DB
                stops = db.query(StationModel.id).all()  # [(8337,), (10293,), …]
                # fire off parallel calls
                coros = [fetch_arrivals(stop_id) for (stop_id,) in stops]
                results = await asyncio.gather(*coros, return_exceptions=True)

                # stash into your cache
                for (stop_id,), res in zip(stops, results):
                    if not isinstance(res, Exception):
                        app.state.arrivals_cache[stop_id] = res
            finally:
                db.close()

            await asyncio.sleep(interval_s)

    asyncio.create_task(refresh_arrivals_loop(60))

    yield
    await app.state.redis.close()

app = FastAPI(lifespan=lifespan, debug=True)

# make sure your tables exist
Base.metadata.create_all(bind=engine)

# mount your stations & arrivals routes
app.include_router(station_router)
