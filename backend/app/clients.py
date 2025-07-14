# app/clients.py
import redis, os

redis_client = redis.from_url(
    os.getenv("REDIS_URL", "redis://localhost:6379/0"),
    db=0,
)