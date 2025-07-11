import re
import httpx
from typing import Iterator
from backend.app.schemas.station import StationOut

OVERPASS_URL = "https://overpass-api.de/api/interpreter"

def parse_overpass(bbox: list[float]) -> Iterator[StationOut]:
    """
    Hit Overpass with a bbox ([min_lon, min_lat, max_lon, max_lat])
    and yield StationOut objects including any TriMet stop tag.
    """
    bbox_str = ",".join(map(str, bbox))
    # grab nodes tagged as stops/platforms
    query = f"""
    [out:json][timeout:25];
    (
      node["public_transport"="platform"]({bbox_str});
      node["public_transport"="stop_position"]({bbox_str});
    );
    out body;
    """
    resp = httpx.get(OVERPASS_URL, params={"data": query})
    resp.raise_for_status()
    data = resp.json()

    for elem in data.get("elements", []):
        tags = elem.get("tags", {})
        osm_id = elem["id"]

        # Try a few common ways people tag the TriMet stop number
        raw = (
            tags.get("ref:trimet")
            or tags.get("gtfs:stop_id")
            or tags.get("trimet:stop_id")
        )
        trimet_id = None
        if raw:
            # extract the leading integer, if any
            m = re.match(r"^(\d+)", raw)
            if m:
                trimet_id = int(m.group(1))

        yield StationOut(
            id=osm_id,
            name=tags.get("name", f"Stop {osm_id}"),
            latitude=elem.get("lat") or elem["center"]["lat"],
            longitude=elem.get("lon") or elem["center"]["lon"],
            description=tags.get("description"),
            trimet_id=trimet_id,
        )
