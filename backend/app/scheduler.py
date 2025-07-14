from apscheduler.schedulers.asyncio import AsyncIOScheduler
from zoneinfo import ZoneInfo

scheduler = AsyncIOScheduler(timezone=ZoneInfo("America/Los_Angeles"))