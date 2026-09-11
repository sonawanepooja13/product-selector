from typing import Optional
from pydantic import BaseModel


class InwardEntryBase(BaseModel):
    date: Optional[str] = ""
    supplier: str
    invoice_no: str
    department: Optional[str] = "Production"
    item_description: Optional[str] = ""
    quantity: float = 1.0
    rate: float = 0.0
    amount: float = 0.0
    payment_status: Optional[str] = "Pending"
    payment_method: Optional[str] = "Cheque"
    cheque_number: Optional[str] = ""
    cheque_date: Optional[str] = ""
    cheque_photo: Optional[str] = ""
    notes: Optional[str] = ""


class InwardEntryCreate(InwardEntryBase):
    pass


class InwardEntryUpdate(BaseModel):
    date: Optional[str] = None
    supplier: Optional[str] = None
    invoice_no: Optional[str] = None
    department: Optional[str] = None
    item_description: Optional[str] = None
    quantity: Optional[float] = None
    rate: Optional[float] = None
    amount: Optional[float] = None
    payment_status: Optional[str] = None
    payment_method: Optional[str] = None
    cheque_number: Optional[str] = None
    cheque_date: Optional[str] = None
    cheque_photo: Optional[str] = None
    notes: Optional[str] = None


class InwardEntryResponse(InwardEntryBase):
    id: int

    class Config:
        from_attributes = True
