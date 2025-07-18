from sqlalchemy import create_engine, Column, String, Integer, Float
from sqlalchemy import BigInteger
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os
# loads .env file variables into environment
load_dotenv()

# reads the database connection
DATABASE_URL=os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

# creates base class for all orm models — each model will inherit from this
Base = declarative_base()

SessionLocal=sessionmaker(bind=engine)

class Stop(Base):
    __tablename__ = "StopTable"

    """
    orm model for the 'StopTable' table.
    represents a transit stop with location and optional metadata.
    """

    id          = Column(Integer, primary_key=True)
    name        = Column(String,  nullable=False)
    latitude    = Column(Float,   nullable=False)   
    longitude   = Column(Float,   nullable=False)  
    dir         = Column(String,  nullable=True)
    trimet_id = Column(BigInteger, unique=True, nullable=True)
    description = Column(String, nullable=True)


class Favorite(Base):
    __tablename__ = "Favorites"
    
    """
    orm model for the 'Favorites' table.
    tracks which routes are favorited for each stop.
    """

    stop_id = Column(Integer, primary_key=True)
    route_id = Column(Integer, primary_key=True)
    route_name = Column(String, nullable=False)