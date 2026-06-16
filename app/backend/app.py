import os
import time
import logging
from typing import List, Dict, Any
from fastapi import FastAPI, Response
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, text
from sqlalchemy.orm import declarative_base, sessionmaker
from prometheus_fastapi_instrumentator import Instrumentator

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("backend")

app = FastAPI(title="Food Delivery Backend API")

# Configure CORS
origins = [
    "http://localhost",
    "http://localhost:5173",
    "http://localhost:80",
    "http://localhost:8080",
    "https://www.harshalpantawane.shop",
    "http://www.harshalpantawane.shop"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database configuration
DB_HOST = os.environ.get("DB_HOST", "")
DB_USER = os.environ.get("DB_USER", "admin")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
DB_NAME = os.environ.get("DB_NAME", "food_delivery")
APP_VERSION = os.environ.get("APP_VERSION", "unknown")

db_url = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"
engine = None
SessionLocal = None
db_connected = False

# Base model for SQLAlchemy
Base = declarative_base()

class Restaurant(Base):
    __tablename__ = 'restaurants'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    rating = Column(Float, default=4.0)
    type = Column(String(50), nullable=False)

# Seed data
MOCK_RESTAURANTS = [
    {"id": 1, "name": "Spice Route (DB)", "rating": 4.8, "type": "Indian"},
    {"id": 2, "name": "Tokyo Drift Sushi (DB)", "rating": 4.6, "type": "Japanese"},
    {"id": 3, "name": "Burger Cartel (DB)", "rating": 4.3, "type": "American"},
    {"id": 4, "name": "La Dolce Vita (DB)", "rating": 4.9, "type": "Italian"}
]

# Fallback local data if DB is unreachable
FALLBACK_RESTAURANTS = [
    {"id": 1, "name": "Spice Route (Fallback)", "rating": 4.8, "type": "Indian"},
    {"id": 2, "name": "Tokyo Drift Sushi (Fallback)", "rating": 4.6, "type": "Japanese"},
    {"id": 3, "name": "Burger Cartel (Fallback)", "rating": 4.3, "type": "American"},
    {"id": 4, "name": "La Dolce Vita (Fallback)", "rating": 4.9, "type": "Italian"}
]

# Initialize Database Connection
if DB_HOST:
    try:
        logger.info(f"Connecting to database at {DB_HOST}...")
        # Add timeout to connect quickly and fail if unreachable instead of hanging
        engine = create_engine(db_url, connect_args={"connect_timeout": 5}, pool_pre_ping=True)
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        
        # Test connection & create tables
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        
        Base.metadata.create_all(bind=engine)
        
        # Seed if empty
        db = SessionLocal()
        if db.query(Restaurant).count() == 0:
            logger.info("Seeding initial restaurant data...")
            for rest in MOCK_RESTAURANTS:
                db.add(Restaurant(id=rest["id"], name=rest["name"], rating=rest["rating"], type=rest["type"]))
            db.commit()
        db.close()
        
        db_connected = True
        logger.info("Successfully connected to RDS MySQL Database!")
    except Exception as e:
        logger.error(f"Failed to connect to database: {str(e)}. Running with graceful local fallback.")
else:
    logger.warning("DB_HOST environment variable not set. Running with local fallback data.")

# Prometheus metrics setup
Instrumentator().instrument(app).expose(app)

@app.get("/health")
def health_check():
    return {"status": "ok", "db_connected": db_connected, "version": APP_VERSION}

@app.get("/info")
def get_info():
    return {"version": APP_VERSION}

@app.get("/restaurants")
def get_restaurants():
    if db_connected and SessionLocal:
        try:
            db = SessionLocal()
            restaurants = db.query(Restaurant).all()
            result = [{"id": r.id, "name": r.name, "rating": r.rating, "type": r.type} for r in restaurants]
            db.close()
            return result
        except Exception as e:
            logger.error(f"Error fetching from DB: {str(e)}. Falling back to local data.")
            return FALLBACK_RESTAURANTS
    return FALLBACK_RESTAURANTS

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3000)
