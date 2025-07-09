# backend/app/utils/trimet.py

import os
import requests
import httpx
from typing import List, Dict

from backend.app.models.station import StationModel

# Your TriMet API key (must be set in env as TRIMET_API_KEY)
TRIMET_KEY = os.getenv("TRIMET_API_KEY")
if not TRIMET_KEY:
    raise RuntimeError("TRIMET_API_KEY environment variable is required")

# Endpoints
TRIMET_STOPS_URL    = "https://developer.trimet.org/ws/V2/stops"
TRIMET_ARRIVALS_URL = "https://developer.trimet.org/ws/V2/arrivals"

# If you want a default bounding box for station loading:
DEFAULT_BBOX = "-122.75,45.45,-122.55,45.65"


#Fetch & persist ALL stops

def fetch_and_load_stations(db, bbox: str | None = None) -> int:
    """
    Pulls every stop in the given bbox from TriMet,
    upserts into your StationModel table, and returns
    how many locations were processed.
    """
    # use user‐supplied bbox or fallback
    bbox_to_use = bbox or DEFAULT_BBOX

    params = {
        "appID": TRIMET_KEY,
        "json":  "true",
        "bbox":  bbox_to_use,
    }

    resp = requests.get(TRIMET_STOPS_URL, params=params, timeout=10)
    resp.raise_for_status()

    # TriMet wraps stops under resultSet → location
    locs = resp.json().get("resultSet", {}).get("location", [])

    for loc in locs:
        # Upsert into your SQLAlchemy model
        db.merge(StationModel(
            id          = loc["locid"],
            name        = loc["desc"],
            latitude    = loc["lat"],
            longitude   = loc["lng"],
            description = loc.get("desc2"),
        ))

    db.commit()
    return len(locs)


#Fetch live arrivals for a single stop

async def fetch_arrivals(stop_id: int) -> List[Dict]:
    """
    Calls TriMet's real-time arrivals endpoint for a single stop ID,
    and returns a list of raw arrival dicts.
    """
    params = {
        "appID":  TRIMET_KEY,
        "locIDs": stop_id,
        "json":   "true",
    }

    async with httpx.AsyncClient() as client:
        resp = await client.get(TRIMET_ARRIVALS_URL, params=params, timeout=10)
        resp.raise_for_status()
        data = resp.json()

    # TriMet wraps arrivals under resultSet → arrival
    return data.get("resultSet", {}).get("arrival", [])
