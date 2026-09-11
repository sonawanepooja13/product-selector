from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import InwardEntry
from app.schemas.finance import (
    InwardEntryCreate,
    InwardEntryUpdate,
    InwardEntryResponse,
)
from app.ws.manager import ws_manager

router = APIRouter(prefix="/finance", tags=["Accounts & Finance"])


def _inward_to_dict(e: InwardEntry) -> dict:
    return {
        "id": e.id,
        "date": e.date or "",
        "supplier": e.supplier,
        "invoice_no": e.invoice_no,
        "department": e.department or "Production",
        "item_description": e.item_description or "",
        "quantity": e.quantity or 1.0,
        "rate": e.rate or 0.0,
        "amount": e.amount or 0.0,
        "payment_status": e.payment_status or "Pending",
        "payment_method": e.payment_method or "Cheque",
        "cheque_number": e.cheque_number or "",
        "cheque_date": e.cheque_date or "",
        "cheque_photo": e.cheque_photo or "",
        "notes": e.notes or "",
    }


@router.get("/inward", response_model=List[InwardEntryResponse])
def list_inward_entries(
    department: Optional[str] = Query(None),
    payment_status: Optional[str] = Query(None),
    supplier: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """List inward entries with optional filtering."""
    q = db.query(InwardEntry)
    if department:
        q = q.filter(InwardEntry.department == department)
    if payment_status:
        q = q.filter(InwardEntry.payment_status.ilike(payment_status))
    if supplier:
        q = q.filter(InwardEntry.supplier.ilike(f"%{supplier}%"))

    entries = q.order_by(InwardEntry.id.desc()).all()
    return [_inward_to_dict(e) for e in entries]


@router.get("/inward/{entry_id}", response_model=InwardEntryResponse)
def get_inward_entry(entry_id: int, db: Session = Depends(get_db)):
    """Fetch single inward entry."""
    e = db.query(InwardEntry).filter(InwardEntry.id == entry_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Inward entry not found")
    return _inward_to_dict(e)


@router.post("/inward", response_model=InwardEntryResponse)
async def create_inward_entry(req: InwardEntryCreate, db: Session = Depends(get_db)):
    """Create a new inward invoice record."""
    amount = req.amount if req.amount > 0 else (req.quantity * req.rate)
    new_entry = InwardEntry(
        date=req.date or "",
        supplier=req.supplier.strip(),
        invoice_no=req.invoice_no.strip(),
        department=req.department or "Production",
        item_description=req.item_description or "",
        quantity=req.quantity,
        rate=req.rate,
        amount=amount,
        payment_status=req.payment_status or "Pending",
        payment_method=req.payment_method or "Cheque",
        cheque_number=req.cheque_number or "",
        cheque_date=req.cheque_date or "",
        cheque_photo=req.cheque_photo or "",
        notes=req.notes or "",
    )
    db.add(new_entry)
    db.commit()
    db.refresh(new_entry)

    data = _inward_to_dict(new_entry)
    await ws_manager.broadcast_event("finance", "create", data)
    return data


@router.put("/inward/{entry_id}", response_model=InwardEntryResponse)
async def update_inward_entry(entry_id: int, req: InwardEntryUpdate, db: Session = Depends(get_db)):
    """Update inward invoice or payment status."""
    e = db.query(InwardEntry).filter(InwardEntry.id == entry_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Inward entry not found")

    update_data = req.dict(exclude_unset=True)
    for field, val in update_data.items():
        if val is not None:
            setattr(e, field, val)

    if req.quantity is not None or req.rate is not None:
        if req.amount is None or req.amount == 0.0:
            e.amount = e.quantity * e.rate

    db.commit()
    db.refresh(e)

    data = _inward_to_dict(e)
    await ws_manager.broadcast_event("finance", "update", data)
    return data


@router.delete("/inward/{entry_id}")
async def delete_inward_entry(entry_id: int, db: Session = Depends(get_db)):
    """Delete an inward invoice record."""
    e = db.query(InwardEntry).filter(InwardEntry.id == entry_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Inward entry not found")

    db.delete(e)
    db.commit()
    await ws_manager.broadcast_event("finance", "delete", {"id": entry_id})
    return {"message": f"Inward entry {entry_id} deleted successfully"}
