from typing import Optional
from pydantic import BaseModel


class CustomerBase(BaseModel):
    name: str
    percentage: float = 0.0
    contact_number: Optional[str] = ""
    email: Optional[str] = ""
    website: Optional[str] = ""
    address: Optional[str] = ""
    category: Optional[str] = "Standard"


class CustomerCreate(CustomerBase):
    pass


class CustomerUpdate(BaseModel):
    name: Optional[str] = None
    percentage: Optional[float] = None
    contact_number: Optional[str] = None
    email: Optional[str] = None
    website: Optional[str] = None
    address: Optional[str] = None
    category: Optional[str] = None


class CustomerResponse(CustomerBase):
    id: int

    class Config:
        from_attributes = True
