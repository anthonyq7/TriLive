from sqlalchemy import create_engine # type: ignore
from sqlalchemy.orm import declarative_base, sessionmaker # type: ignore

#database connection in string format
DATABASE_URL = "postgresql://postgres:portland>seattle@localhost:5432/trilive"

#sqlalchemy engine handles the actual connection to the database
engine = create_engine(DATABASE_URL)

#this is useed to establish the session between the database and the app
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False)

#the base class is used to define tables that inherit from it
Base = declarative_base()
