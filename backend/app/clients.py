import os, redis
# Constructs Redis connection URL from the REDIS_URL environment variable
# falling back to a local Redis instance if not set.
redis_client = redis.from_url(
    os.getenv("REDIS_URL", "redis://localhost:6379/0"),
)
