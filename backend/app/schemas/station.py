from pydantic import BaseModel
from typing import Optional

#used to validate the station data from the api we use
class Station(BaseModel):
    id:        int
    name:      str
    latitude:  float
    longitude: float
    description: Optional[str] = None

    class Config:
        orm_mode = True

class Arrival(BaseModel):
    route:     int
    scheduled: int
    estimated: int | None
    vehicle:   int | None

class StationOut(BaseModel):
    id:            int
    name:          str
    latitude:      float
    longitude:     float
    description:   Optional[str] = None

    class Config:
        # for Pydantic v2
        from_attributes = True
        # if you’re on v1, use orm_mode instead:
        # orm_mode = True