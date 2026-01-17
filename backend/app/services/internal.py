from fastapi import APIRouter, HTTPException, Depends
from typing import Optional
import httpx

# Internal imports
from app.schemas.internal import DetailsRequest
from app.services.auth import get_current_user
from app.models import User
from app.database import get_session
from sqlmodel.ext.asyncio.session import AsyncSession
from app.integrations.app import analyze_nutrition

router = APIRouter()

@router.post("/details")
async def get_product_details(request: DetailsRequest,db: AsyncSession = Depends(get_session)):
    current_user = await get_current_user(request.token,db)
    if not current_user:
        raise HTTPException(status_code=401, detail="Invalid auth token")

    async with httpx.AsyncClient() as client:
        if request.barcode:
            url = f"https://world.openfoodfacts.net/api/v2/product/{request.barcode}"
            params = {
                "fields": "product_name,nutrition_grades,nutriments,image_url,code,"
        "nutrient_levels,serving_size,ingredients_text,nova_group,"
        "ingredients_analysis_tags,categories_tags,categories"
            }
            try:
                response = await client.get(url, params=params)
                data = response.json()
                if data.get("status") != 1:
                    raise HTTPException(status_code=404, detail="Product not found by barcode")
                return {
                    "product": data.get("product"),
                    "aifeedback": analyze_nutrition(
                    nutrition=data.get("product"),
                    disease = current_user.health_issues or "",
                    goals = current_user.goals or "",
                    allergies = current_user.dietary_preferences or ""
                    )}
            except httpx.RequestError:
                raise HTTPException(status_code=503, detail="External API unavailable")

        elif request.product_name:
            url = "https://world.openfoodfacts.org/cgi/search.pl"
            
            params = {
                "search_terms": request.product_name,
                "search_simple": 1,
                "action": "process",
                "json": 1,
                "page_size": 1,
                "fields": "product_name,nutrition_grades,nutriments,image_url,code"
            }
            
            try:
                response = await client.get(url, params=params)
                data = response.json()
                
                products = data.get("products", [])
                if not products:
                    raise HTTPException(status_code=404, detail="Product not found by name")
                return {
                    "source": "search",
                    "product": products[0]
                }
            except httpx.RequestError:
                raise HTTPException(status_code=503, detail="External API unavailable")
        else:
            raise HTTPException(
                status_code=400, 
                detail="Please provide either a 'barcode' or a 'product_name'"
            )