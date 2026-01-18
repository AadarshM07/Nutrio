from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession
from typing import List

   
from app.models import User, ChatHistory
from app.database import get_session
from app.services.auth import get_current_user
   
from app.integrations.app import NutritionAnalyzer

router = APIRouter()

   
class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str
    timestamp: str

   

@router.post("/", response_model=ChatResponse)
async def chat_with_nutrio(
    request: ChatRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session)
):
    """
    Endpoint to chat with the AI.
    1. Authenticates user.
    2. Fetches recent chat history.
    3. Generates AI response.
    4. Saves interaction to DB.
    """
       
       
    statement = (
        select(ChatHistory)
        .where(ChatHistory.user_id == current_user.id)
        .order_by(ChatHistory.timestamp.desc())
        .limit(10)
    )
    result = await db.exec(statement)
    history_records = result.all()
    
       
    history_context = ""
    for record in reversed(history_records):
        history_context += f"User: {record.message}\nAI: {record.response}\n"

    if not history_context:
        history_context = "No previous conversation."

       
    user_profile = {
        "name": current_user.name,
        "disease": current_user.health_issues,
        "goals": current_user.goals,
        "allergies": current_user.dietary_preferences
    }

       
    ai_result = NutritionAnalyzer.process_chat_message(
        user_message=request.message,
        user_profile=user_profile,
        history_context=history_context
    )

    ai_text = ai_result['response']

       
    new_chat_entry = ChatHistory(
        user_id=current_user.id,
        message=request.message,
        response=ai_text
    )
    
    db.add(new_chat_entry)
    await db.commit()
    await db.refresh(new_chat_entry)

    return {
        "response": ai_text,
        "timestamp": new_chat_entry.timestamp.isoformat()
    }

@router.get("/history", response_model=List[dict])
async def get_chat_history(
    token: str,
    db: AsyncSession = Depends(get_session)
):
    """
    Optional: Endpoint to load previous messages when the user opens the chat screen.
    """
    current_user = await get_current_user(token, db)
    if not current_user:
        raise HTTPException(status_code=401, detail="Invalid auth token")

    statement = (
        select(ChatHistory)
        .where(ChatHistory.user_id == current_user.id)
        .order_by(ChatHistory.timestamp.asc()) 
    )
    result = await db.exec(statement)
    history = result.all()

    return [
        {
            "message": h.message,
            "response": h.response,
            "timestamp": h.timestamp
        } for h in history
    ]