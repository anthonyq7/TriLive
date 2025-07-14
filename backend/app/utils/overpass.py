# app/utils/overpass.py

import httpx
from typing import List, Dict

OVERPASS_URL = "https://overpass-api.de/api/interpreter"

async def parse_overpass(bbox: List[float]) -> List[Dict]:
    """
    Fetches all nodes (e.g. bus stops) within the given bbox
    and returns them as a list of dicts matching your Station schema.
    """
    # build Overpass QL query
    query = f"""
    [out:json][timeout:25];
    (
    node["public_transport"="stop_position"]({bbox[1]},{bbox[0]},{bbox[3]},{bbox[2]});
    );
    out body;
    """
    async with httpx.AsyncClient() as client:
        resp = await client.post(OVERPASS_URL, data={"data": query})
        resp.raise_for_status()

    elements = resp.json().get("elements", [])
    stations: List[Dict] = []
    for el in elements:
        stations.append({
            # we’ll let SQLAlchemy auto-assign our PK `id`
            "trimet_id":   el["id"],
            "name":        el.get("tags", {}).get("name", ""),
            "latitude":    el["lat"],
            "longitude":   el["lon"],
            "description": el.get("tags", {}).get("public_transport", ""),
        })
    return stations
