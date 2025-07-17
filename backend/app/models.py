from pydantic import BaseModel, Field

class Route(BaseModel):
    route_id:    int
    route_name:  str
    status:      str
    eta:         int
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
    trimet_id: int = Field(default=None, alias="stop_id")

    class Config:
        orm_mode = True
        model_config = {
        "extra": "ignore",
    }
