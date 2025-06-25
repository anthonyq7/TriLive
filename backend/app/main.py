from fastapi import FastAPI
from contextlib import asynccontextmanager
import redis.asyncio as redis

from backend.app.db.database import Base, engine
from backend.app.routers import station

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.state.redis = redis.Redis(host="localhost", port=6379, decode_responses=True)
    yield
    await app.state.redis.aclose()

app = FastAPI(lifespan=lifespan)

Base.metadata.create_all(bind=engine)

#mounts the routes
app.include_router(station.router)
