from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.db.database import get_db
from app.db.models import CrmContact, CrmDeal, CrmInteraction
from app.schemas.crm import (
    CrmContactCreate,
    CrmContactUpdate,
    CrmContactResponse,
    CrmInteractionCreate,
    CrmInteractionResponse,
    CrmMetricsResponse,
)
from app.ws.manager import ws_manager

router = APIRouter(prefix="/crm", tags=["CRM & Leads"])


def _contact_to_dict(c: CrmContact) -> dict:
    return {
        "id": c.id,
        "company_name": c.company_name,
        "primary_contact": c.primary_contact or "",
        "email": c.email or "",
        "phone": c.phone or "",
        "status": c.status or "New",
        "category": c.category or "Booster Pump Control Panel",
        "estimated_value": c.estimated_value or 0.0,
        "stage": c.stage or "new",
        "notes": c.notes or "",
        "lead_score": c.lead_score or 0,
        "created_at": c.created_at,
    }


@router.get("/contacts", response_model=List[CrmContactResponse])
def list_contacts(db: Session = Depends(get_db)):
    """List all CRM leads/contacts."""
    contacts = db.query(CrmContact).order_by(CrmContact.created_at.desc()).all()
    return [_contact_to_dict(c) for c in contacts]


@router.get("/contacts/{contact_id}", response_model=CrmContactResponse)
def get_contact(contact_id: int, db: Session = Depends(get_db)):
    """Fetch single CRM contact."""
    c = db.query(CrmContact).filter(CrmContact.id == contact_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Contact not found")
    return _contact_to_dict(c)


@router.post("/contacts", response_model=CrmContactResponse)
async def create_contact(req: CrmContactCreate, db: Session = Depends(get_db)):
    """Create a new CRM contact/lead."""
    new_contact = CrmContact(
        company_name=req.company_name.strip(),
        primary_contact=req.primary_contact or "",
        email=req.email or "",
        phone=req.phone or "",
        status=req.status or "New",
        category=req.category or "Booster Pump Control Panel",
        estimated_value=req.estimated_value or 0.0,
        stage=req.stage or "new",
        notes=req.notes or "",
        lead_score=req.lead_score or 0,
    )
    db.add(new_contact)
    db.commit()
    db.refresh(new_contact)

    data = _contact_to_dict(new_contact)
    await ws_manager.broadcast_event("crm", "create", data)
    return data


@router.put("/contacts/{contact_id}", response_model=CrmContactResponse)
async def update_contact(contact_id: int, req: CrmContactUpdate, db: Session = Depends(get_db)):
    """Update contact information or pipeline stage."""
    c = db.query(CrmContact).filter(CrmContact.id == contact_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Contact not found")

    update_data = req.dict(exclude_unset=True)
    for field, val in update_data.items():
        if val is not None:
            setattr(c, field, val)

    db.commit()
    db.refresh(c)

    data = _contact_to_dict(c)
    await ws_manager.broadcast_event("crm", "update", data)
    return data


@router.delete("/contacts/{contact_id}")
async def delete_contact(contact_id: int, db: Session = Depends(get_db)):
    """Delete a CRM contact."""
    c = db.query(CrmContact).filter(CrmContact.id == contact_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Contact not found")

    db.delete(c)
    db.commit()
    await ws_manager.broadcast_event("crm", "delete", {"id": contact_id})
    return {"message": f"Contact {contact_id} deleted successfully"}


@router.post("/interactions", response_model=CrmInteractionResponse)
async def create_interaction(req: CrmInteractionCreate, db: Session = Depends(get_db)):
    """Log an interaction with a contact."""
    c = db.query(CrmContact).filter(CrmContact.id == req.contact_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Contact not found")

    interaction = CrmInteraction(
        contact_id=req.contact_id,
        type=req.type,
        summary=req.summary,
    )
    db.add(interaction)
    db.commit()
    db.refresh(interaction)

    return {
        "id": interaction.id,
        "contact_id": interaction.contact_id,
        "type": interaction.type,
        "summary": interaction.summary,
        "logged_at": interaction.logged_at,
    }


@router.get("/metrics", response_model=CrmMetricsResponse)
def get_metrics(db: Session = Depends(get_db)):
    """Returns aggregated pipeline metrics."""
    total_val = db.query(func.sum(CrmContact.estimated_value)).scalar() or 0.0
    total_contacts = db.query(CrmContact).count()
    active_leads = db.query(CrmContact).filter(CrmContact.status.notin_(["Lost", "Closed"])).count()

    stage_counts = (
        db.query(CrmContact.stage, func.count(CrmContact.id))
        .group_by(CrmContact.stage)
        .all()
    )
    stage_breakdown = {stage: count for stage, count in stage_counts}

    return CrmMetricsResponse(
        total_pipeline_value=float(total_val),
        active_leads=active_leads,
        total_contacts=total_contacts,
        stage_breakdown=stage_breakdown,
    )
