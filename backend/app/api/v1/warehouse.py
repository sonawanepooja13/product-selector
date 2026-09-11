from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import WarehouseItem
from app.schemas.warehouse import (
    WarehouseItemCreate,
    WarehouseItemUpdate,
    WarehouseItemResponse,
)
from app.ws.manager import ws_manager

router = APIRouter(prefix="/warehouse", tags=["Warehouse & Inventory"])


def _item_to_dict(i: WarehouseItem) -> dict:
    return {
        "id": i.id,
        "item_code": i.item_code,
        "item_name": i.item_name,
        "category": i.category or "Components",
        "quantity": i.quantity,
        "unit": i.unit or "Pcs",
        "location": i.location or "Main Warehouse",
        "reorder_level": i.reorder_level or 5.0,
    }


@router.get("/items", response_model=List[WarehouseItemResponse])
def list_items(
    category: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List inventory items."""
    q = db.query(WarehouseItem)
    if category:
        q = q.filter(WarehouseItem.category == category)
    items = q.order_by(WarehouseItem.item_code.asc()).all()
    return [_item_to_dict(i) for i in items]


@router.get("/items/{item_id}", response_model=WarehouseItemResponse)
def get_item(item_id: int, db: Session = Depends(get_db)):
    """Fetch single warehouse item."""
    i = db.query(WarehouseItem).filter(WarehouseItem.id == item_id).first()
    if not i:
        raise HTTPException(status_code=404, detail="Item not found")
    return _item_to_dict(i)


@router.post("/items", response_model=WarehouseItemResponse)
async def create_item(req: WarehouseItemCreate, db: Session = Depends(get_db)):
    """Create a new warehouse item."""
    existing = db.query(WarehouseItem).filter(WarehouseItem.item_code == req.item_code.strip()).first()
    if existing:
        raise HTTPException(status_code=400, detail=f"Item with code {req.item_code} already exists")

    new_item = WarehouseItem(
        item_code=req.item_code.strip(),
        item_name=req.item_name.strip(),
        category=req.category or "Components",
        quantity=req.quantity,
        unit=req.unit or "Pcs",
        location=req.location or "Main Warehouse",
        reorder_level=req.reorder_level or 5.0,
    )
    db.add(new_item)
    db.commit()
    db.refresh(new_item)

    data = _item_to_dict(new_item)
    await ws_manager.broadcast_event("warehouse", "create", data)
    return data


@router.put("/items/{item_id}", response_model=WarehouseItemResponse)
async def update_item(item_id: int, req: WarehouseItemUpdate, db: Session = Depends(get_db)):
    """Update warehouse item or adjust quantity."""
    i = db.query(WarehouseItem).filter(WarehouseItem.id == item_id).first()
    if not i:
        raise HTTPException(status_code=404, detail="Item not found")

    update_data = req.dict(exclude_unset=True)
    for field, val in update_data.items():
        if val is not None:
            setattr(i, field, val)

    db.commit()
    db.refresh(i)

    data = _item_to_dict(i)
    await ws_manager.broadcast_event("warehouse", "update", data)
    return data


@router.delete("/items/{item_id}")
async def delete_item(item_id: int, db: Session = Depends(get_db)):
    """Delete a warehouse item."""
    i = db.query(WarehouseItem).filter(WarehouseItem.id == item_id).first()
    if not i:
        raise HTTPException(status_code=404, detail="Item not found")

    db.delete(i)
    db.commit()
    await ws_manager.broadcast_event("warehouse", "delete", {"id": item_id})
    return {"message": f"Item {item_id} deleted successfully"}
