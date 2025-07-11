import httpx
from backend.app.schemas.station import StationOut

OVERPASS_URL = "https://overpass-api.de/api/interpreter"

def parse_overpass(bbox: list[float]) -> list[StationOut]:
    # bbox comes in as [min_lon, min_lat, max_lon, max_lat]
    min_lon, min_lat, max_lon, max_lat = bbox
    # Overpass wants (south,west,north,east):
    south, west, north, east = min_lat, min_lon, max_lat, max_lon

    query = f"""
    [out:json][timeout:25];
    (
    node["public_transport"="platform"]({south},{west},{north},{east});
    node["public_transport"="stop_position"]({south},{west},{north},{east});
    );
    out body;
    """

    resp = httpx.get(OVERPASS_URL, params={"data": query})
    try:
        resp.raise_for_status()
    except httpx.HTTPStatusError as e:
        # bubble a FastAPI-friendly error
        raise RuntimeError(f"Overpass API returned {e.response.status_code}: {e.response.text}")

    data = resp.json()
    stations = []
    for el in data.get("elements", []):
        tags = el.get("tags", {})
        trimet_ref = tags.get("ref:trimet") or tags.get("ref")
        stations.append(
            StationOut(
                id=int(el["id"]),
                name=tags.get("name", ""),
                latitude=el["lat"],
                longitude=el["lon"],
                description=tags.get("name:en"),
                trimet_id=int(trimet_ref) if trimet_ref and trimet_ref.isdigit() else None,
            )
        )
    return stations
