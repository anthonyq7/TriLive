# backend/app/utils/trimet.py

import os
import requests
import httpx
from typing import List, Dict

from backend.app.models.station import StationModel

# Your TriMet API key
TRIMET_KEY = os.getenv("TRIMET_API_KEY")
if not TRIMET_KEY:
    raise RuntimeError("TRIMET_API_KEY environment variable is required")

# Endpoints
BASE_URL            = "https://developer.trimet.org/ws/v2"
TRIMET_STOPS_URL    = f"{BASE_URL}/stops"
TRIMET_ARRIVALS_URL = f"{BASE_URL}/arrivals"

# Default bounding box
DEFAULT_BBOX = "-122.75,45.45,-122.55,45.65"


def fetch_and_load_stations(db, bbox: str | None = None) -> int:
    """
    Pull every stop in the given bbox from TriMet,
    upsert into your StationModel table, and return
    how many locations were processed.
    """
    bbox_to_use = bbox or DEFAULT_BBOX
    params = {
        "appID": TRIMET_KEY,
        "json":  "true",
        "bbox":  bbox_to_use,
    }

    resp = requests.get(TRIMET_STOPS_URL, params=params, timeout=10)
    resp.raise_for_status()
    locs = resp.json().get("resultSet", {}).get("location", [])

    for loc in locs:
        db.merge(StationModel(
            id          = loc["locid"],
            name        = loc["desc"],
            latitude    = loc["lat"],
            longitude   = loc["lng"],
            description = loc.get("desc2"),
        ))

    db.commit()
    return len(locs)


async def fetch_arrivals(stop_id: int) -> List[Dict]:
    """
    Call TriMet’s real‐time arrivals endpoint for a single stop ID,
    and return a list of raw arrival dicts.
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

    return data.get("resultSet", {}).get("arrival", [])
