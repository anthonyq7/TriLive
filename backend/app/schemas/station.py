from pydantic import BaseModel
from typing import Optional

#used to validate the station data from the api we use
class Station(BaseModel):
    id: int                   
    name: str
    latitude: float
    longitude: float
    description: Optional[str] = None 

#tells the api if its okay to convert the SQLALCHEMY model to pydantic response
class Config:
    orm_mode = True