from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession
from typing import List

# Internal Imports
from app.models import User, Inventory
from app.database import get_session
from app.services.auth import get_current_user
from app.schemas.dashboard import DashboardAnalysisResponse
from app.integrations.app import generate_dashboard_stats

router = APIRouter()

@router.get("/stats", response_model=DashboardAnalysisResponse)
async def get_dashboard_stats(
    timeline: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session)
):
    """
    Generates AI-powered dashboard statistics based on the user's current inventory
    and health profile.
    """
    # 1. Fetch User Inventory
    statement = select(Inventory).where(Inventory.user_id == current_user.id)
    result = await db.exec(statement)
    inventory_items = result.all()

    # 2. Prepare User Profile Dict
    user_profile = {
        "name": current_user.name,
        "gender": current_user.gender,
        "disease": current_user.health_issues,
        "goals": current_user.goals,
        "allergies": current_user.dietary_preferences
    }

    # 3. Call AI Service
    # This function (defined in app.integrations.app) handles the RAG + Prompting
    analysis_result = generate_dashboard_stats(user_profile, inventory_items,timeline)

    return analysis_result