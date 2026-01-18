from sqlmodel import SQLModel, Field
from typing import Optional
from datetime import datetime

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(index=True, unique=True)
    name: str 
    password_hash: str    
    gender: Optional[str] = None
       
    health_issues: Optional[str] = None
    dietary_preferences: Optional[str] = None
    goals: Optional[str] = None
    weight: Optional[int] = None
    height: Optional[int] = None
    health_details:Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.now)


class ChatHistory(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    message: str
    response: str
    timestamp: datetime = Field(default_factory=datetime.now)


class Inventory(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.id")
    barcode: str = Field(primary_key=True)
    title: str
    img: str
    tag: str
    nutrient_score: str
    product_data: str     
    ai_feedback: str     
    timestamp: datetime = Field(default_factory=datetime.now)


