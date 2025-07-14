from pydantic import BaseModel

class Route(BaseModel):
    stop_id: int #parent stop id here
    route_id: int
    route_name: str
    status: str
    eta: str
    routeColor: str

class Station(BaseModel):
    stop_id: int
    name: str
    dir: str
    lon: float
    lat: float
    dist: int

