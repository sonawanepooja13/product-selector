from typing import Optional
from pydantic import BaseModel


class ProductBase(BaseModel):
    pump_current: float
    num_pumps: int
    num_vfd: int
    bypass: str = "Without Bypass"
    panel_type: str = "Indoor"
    panel_size: str = "400x300"
    panel_class: str = "Industrial"
    main_incomer: str = "Yes"
    olr_required: str = "Yes"
    indicator_light: str = "Yes"
    price: float
    category: Optional[str] = "Booster Pump Control Panel"
    notes: Optional[str] = ""


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    pump_current: Optional[float] = None
    num_pumps: Optional[int] = None
    num_vfd: Optional[int] = None
    bypass: Optional[str] = None
    panel_type: Optional[str] = None
    panel_size: Optional[str] = None
    panel_class: Optional[str] = None
    main_incomer: Optional[str] = None
    olr_required: Optional[str] = None
    indicator_light: Optional[str] = None
    price: Optional[float] = None
    category: Optional[str] = None
    notes: Optional[str] = None


class ProductResponse(ProductBase):
    id: int

    class Config:
        from_attributes = True


class ProductSearchQuery(BaseModel):
    pump_current: Optional[float] = None
    num_pumps: Optional[int] = None
    num_vfd: Optional[int] = None
    bypass: Optional[str] = None
    panel_type: Optional[str] = None
    panel_size: Optional[str] = None
    panel_class: Optional[str] = None
    main_incomer: Optional[str] = None
    olr_required: Optional[str] = None
    indicator_light: Optional[str] = None
    category: Optional[str] = None
