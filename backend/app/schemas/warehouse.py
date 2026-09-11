from typing import Optional
from pydantic import BaseModel


class WarehouseItemBase(BaseModel):
    item_code: str
    item_name: str
    category: Optional[str] = "Components"
    quantity: float = 0.0
    unit: Optional[str] = "Pcs"
    location: Optional[str] = "Main Warehouse"
    reorder_level: Optional[float] = 5.0


class WarehouseItemCreate(WarehouseItemBase):
    pass


class WarehouseItemUpdate(BaseModel):
    item_name: Optional[str] = None
    category: Optional[str] = None
    quantity: Optional[float] = None
    unit: Optional[str] = None
    location: Optional[str] = None
    reorder_level: Optional[float] = None


class WarehouseItemResponse(WarehouseItemBase):
    id: int

    class Config:
        from_attributes = True
