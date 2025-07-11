from sqlalchemy import Column, BigInteger, String, Float, Integer
from backend.app.db.database import Base

class StationModel(Base):
    __tablename__ = "stations"

    # switch from Integer → BigInteger so we can store Overpass node IDs
    trimet_id  = Column(Integer, nullable=True) 
    id          = Column(BigInteger, primary_key=True, index=True)
    name        = Column(String,   nullable=False)
    latitude    = Column(Float,    nullable=False)
    longitude   = Column(Float,    nullable=False)
    description = Column(String)
