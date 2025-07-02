from pydantic import BaseModel

class Station(BaseModel):
    id: int
    name: str
    address: str
    latitude: float
    longitude: float



