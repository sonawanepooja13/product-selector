from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel


class CrmContactBase(BaseModel):
    company_name: str
    primary_contact: Optional[str] = ""
    email: Optional[str] = ""
    phone: Optional[str] = ""
    status: Optional[str] = "New"
    category: Optional[str] = "Booster Pump Control Panel"
    estimated_value: Optional[float] = 0.0
    stage: Optional[str] = "new"
    notes: Optional[str] = ""
    lead_score: Optional[int] = 0


class CrmContactCreate(CrmContactBase):
    pass


class CrmContactUpdate(BaseModel):
    company_name: Optional[str] = None
    primary_contact: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    status: Optional[str] = None
    category: Optional[str] = None
    estimated_value: Optional[float] = None
    stage: Optional[str] = None
    notes: Optional[str] = None
    lead_score: Optional[int] = None


class CrmContactResponse(CrmContactBase):
    id: int
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class CrmInteractionCreate(BaseModel):
    contact_id: int
    type: str  # Call, Meeting, Email, Note
    summary: str


class CrmInteractionResponse(CrmInteractionCreate):
    id: int
    logged_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class CrmMetricsResponse(BaseModel):
    total_pipeline_value: float
    active_leads: int
    total_contacts: int
    stage_breakdown: dict
