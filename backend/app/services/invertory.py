from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession
from typing import List
from app.schemas.inventory import InventoryAddRequest

   
from app.models import User, Inventory
from app.database import get_session
from app.services.auth import get_current_user 

router = APIRouter()

@router.get("/", response_model=List[Inventory])
async def get_user_inventory(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session)
):
    """
    Retrieve all inventory items for the currently authenticated user.
    """
    try:
        statement = select(Inventory).where(Inventory.user_id == current_user.id)
        result = await db.exec(statement)
        return result.all()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=f"Error fetching inventory: {str(e)}"
        )

@router.post("/add/", response_model=Inventory, status_code=201)
async def add_to_inventory(
    item_data: InventoryAddRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_session)
):
    """
    Add a new product to the user's inventory.
    """
       
       
    statement = select(Inventory).where(
        Inventory.user_id == current_user.id, 
        Inventory.barcode == item_data.barcode
    )
    result = await db.exec(statement)
    existing_item = result.first()

    if existing_item:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Product already exists in your inventory."
        )

       
    new_item = Inventory(
        user_id=current_user.id,
        barcode=item_data.barcode,
        title=item_data.title,
        img=item_data.img,
        tag=item_data.tag,
        nutrient_score=item_data.nutrient_score,
        product_data=item_data.product_data,
        ai_feedback=item_data.ai_feedback
    )

    try:
        db.add(new_item)
        await db.commit()
        await db.refresh(new_item)
        return new_item
    except Exception as e:
        await db.rollback()
           
           
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Could not add item. It might already exist in the system. Error: {str(e)}"
        )