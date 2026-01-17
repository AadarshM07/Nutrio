from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.database import engine, get_session
from app.models import User
from app.services.auth import router as auth_router # Assuming auth.py is in the same folder or adjusted path
from app.services.internal import router as internal_router 


# Create tables on startup (For development only)
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(User.metadata.create_all)
    yield

app = FastAPI(lifespan=lifespan)

app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(internal_router, prefix="/v1", tags=["v1"])