from pydantic import BaseModel


class InventoryAddRequest(BaseModel):
    barcode: str
    title: str
    img: str
    tag: str
    nutrient_score: str
    product_data: str
    ai_feedback: str 
