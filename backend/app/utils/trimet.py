import requests, os
from backend.app.models.station import StationModel

TRIMET_KEY   = os.getenv("TRIMET_API_KEY")
TRIMET_V2    = "https://developer.trimet.org/ws/V2/stops"
DEFAULT_BBOX = "-122.75,45.45,-122.55,45.65"

def fetch_and_load_stations(db, bbox: str | None = None) -> int:
    if not TRIMET_KEY:
        raise RuntimeError("TRIMET_API_KEY not set")
    # use user‐supplied bbox or default
    bbox_to_use = bbox or DEFAULT_BBOX
    params = {
        "appID": TRIMET_KEY,
        "json":  "true",
        "bbox":  bbox_to_use,
    }
    resp = requests.get(TRIMET_V2, params=params, timeout=10)
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