import os
import requests
from typing import Iterator, Tuple
from app.schemas.station import StationOut

# Public Overpass endpoint—no signup required
OVERPASS_URL = os.getenv(
    "OVERPASS_URL",
    "https://overpass-api.de/api/interpreter"
)

def parse_overpass(
    bbox: Tuple[float, float, float, float]
) -> Iterator[StationOut]:
    """
    Query Overpass for stops in the given (west, south, east, north) bbox,
    and yield StationOut models.
    """
    west, south, east, north = bbox
    # Overpass-QL: find all nodes tagged as public_transport=platform
    query = f"""
    [out:json][timeout:25];
    (
    node["public_transport"="platform"]({south},{west},{north},{east});
    );
    out body;
    """
    resp = requests.post(OVERPASS_URL, data={"data": query})
    resp.raise_for_status()
    data = resp.json().get("elements", [])
    for el in data:
        yield StationOut(
            id=el["id"],
            name=el.get("tags", {}).get("name", ""),
            latitude=el.get("lat"),
            longitude=el.get("lon"),
            description=el.get("tags", {}).get("description"),
        )
