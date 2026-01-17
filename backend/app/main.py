from fastapi import FastAPI
from contextlib import asynccontextmanager
from app.database import engine, get_session
from app.models import User
from app.services.auth import router as auth_router # Assuming auth.py is in the same folder or adjusted path
from app.services.internal import router as internal_router 
from app.services.chat import router as chat_router 
from app.services.invertory import router as inventory_router
from app.services.dashboard import router as  dashboard_router


# Create tables on startup (For development only)
@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(User.metadata.create_all)
    yield

app = FastAPI(lifespan=lifespan)

app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(internal_router, prefix="/v1", tags=["v1"])
app.include_router(chat_router, prefix="/chat", tags=["Chat"])
app.include_router(inventory_router, prefix="/inv", tags=["Inventory"])
app.include_router(dashboard_router, prefix="/dashboard", tags=["Dashboard"])