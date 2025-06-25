from fastapi import FastAPI
from redis.asyncio import Redis
import os, json

app = FastAPI()
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")

@app.on_event("startup")
async def open_redis():
    app.state.redis = Redis.from_url(REDIS_URL, decode_responses=True)

@app.on_event("shutdown")
async def close_redis():
    await app.state.redis.close()

@app.get("/ping")
async def ping():
    return {"pong": True}
