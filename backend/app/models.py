from sqlalchemy import Column, Integer, String, Float # type: ignore
from database import Base

#this is the station table schema in the database, name, id and the other fields
class StationModel(Base):
    __tablename__ = "stations"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    description = Column(String)