from fastapi import FastAPI
from contextlib import asynccontextmanager
import os
import redis.asyncio as redis

from backend.app.db.database import Base, engine
from backend.app.routers import station

@asynccontextmanager
async def lifespan(app: FastAPI):
    url = os.getenv("REDIS_URL", "redis://localhost:6379")
    app.state.redis = await redis.from_url(url, decode_responses=True)
    yield
    await app.state.redis.close()

app = FastAPI(lifespan=lifespan, debug=True)

@app.get("/ping")
async def ping():
    return {"pong": True}

Base.metadata.create_all(bind=engine)

#mounts the routes
app.include_router(station.router)
