import httpx
from backend.app.schemas.station import Station

OVERPASS_URL = "https://overpass-api.de/api/interpreter"

def parse_overpass(bbox: list[float]) -> list[Station]:
    # build & fire your Overpass QL request...
    query = f"""
    [out:json][timeout:25];
    (
    node["public_transport"="platform"]({bbox[1]},{bbox[0]},{bbox[3]},{bbox[2]});
    node["public_transport"="stop_position"]({bbox[1]},{bbox[0]},{bbox[3]},{bbox[2]});
    );
    out body;
    """
    resp = httpx.get(OVERPASS_URL, params={"data": query})
    resp.raise_for_status()
    data = resp.json()

    stations: list[Station] = []
    for elem in data["elements"]:
        tags = elem.get("tags", {})
        stations.append(
            Station(
                id=elem["id"],
                trimet_id=int(tags["ref"]) if tags.get("ref") and tags["ref"].isdigit() else None,
                name=tags.get("name", ""),
                latitude=elem["lat"],
                longitude=elem["lon"],
                description=tags.get("description"),
            )
        )
    return stations
