from typing import Optional
from pydantic import BaseModel, EmailStr

class RegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str

class LoginRequest(BaseModel):
    email: EmailStr 
    password: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: EmailStr
    weight: Optional[int] = None
    height: Optional[int] = None
    health_details:Optional[str] = None
    gender: Optional[str] = None 
    health_issues: Optional[str] = None
    dietary_preferences: Optional[str] = None
    goals: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str