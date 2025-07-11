from pydantic import BaseModel
from typing   import Optional

# shared fields
class StationBase(BaseModel):
    name:        str
    latitude:    float
    longitude:   float
    description: Optional[str] = None

# used for inbound POST/PUT (you won’t actually send an ID here)
class StationCreate(StationBase):
    pass

# what you return on GET /stations and GET /stations/{id}
class Station(BaseModel):
    id:         int
    name:       str
    latitude:   float
    longitude:  float
    description: Optional[str] = None
    trimet_id:  Optional[int]   = None

    class Config:
        orm_mode = True

    class Config:
        # Pydantic v1
        orm_mode = True
        # if you’re on Pydantic v2, use instead:
        # from_attributes = True

# identical to Station, but shows how you could alias or
# add extra fields for “output”‐only models
class StationOut(BaseModel):
    id:          int
    name:        str
    latitude:    float
    longitude:   float
    description: Optional[str] = None
    trimet_id:   Optional[int]   = None

    class Config:
        from_attributes = True

class Arrival(BaseModel):
    route:     int
    scheduled: int
    estimated: Optional[int] = None
    vehicle:   Optional[int] = None


