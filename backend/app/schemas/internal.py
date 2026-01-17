from typing import Optional
from pydantic import BaseModel, EmailStr

class DetailsRequest(BaseModel):
    token: str
    product_name: Optional[str] = None
    barcode: Optional[str] = None

class ChatRequest(BaseModel):
    user_id: int
    message: str

class CompareRequest(BaseModel):
    token: str
    product1: dict  # Full product data for first product
    product2: dict  # Full product data for second product