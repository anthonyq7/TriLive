from sqlalchemy import create_engine, Column, String, Integer, Float
from sqlalchemy import BigInteger
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

load_dotenv()
DATABASE_URL=os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Base = declarative_base()

SessionLocal=sessionmaker(bind=engine)

class Stop(Base):
    __tablename__ = "StopTable"

    id          = Column(Integer, primary_key=True)
    name        = Column(String,  nullable=False)
    latitude    = Column(Float,   nullable=False)   
    longitude   = Column(Float,   nullable=False)  
    dir         = Column(String,  nullable=True)
    trimet_id = Column(BigInteger, unique=True, nullable=True)
    description = Column(String, nullable=True)


class Favorite(Base):
    __tablename__ = "Favorites"
    stop_id = Column(Integer, primary_key=True)
    route_id = Column(Integer, primary_key=True)
    route_name = Column(String, nullable=False)