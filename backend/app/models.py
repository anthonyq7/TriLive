from pydantic import BaseModel, Field
from datetime import datetime

class Route(BaseModel):
    route_id:    int
    route_name:  str
    status:      str
    eta:         datetime
    route_color: str = Field(alias="routeColor")

    class Config:
        orm_mode = True
        allow_population_by_field_name = True  
        
class Station(BaseModel):
    stop_id: int
    name:    str
    dir:     str
    lon:     float
    lat:     float
    dist:    int

    class Config:
        orm_mode = True
