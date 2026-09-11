from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import Customer
from app.schemas.customer import (
    CustomerCreate,
    CustomerUpdate,
    CustomerResponse,
)
from app.ws.manager import ws_manager

router = APIRouter(prefix="/customers", tags=["Customers"])


def _customer_to_dict(c: Customer) -> dict:
    return {
        "id": c.id,
        "name": c.name,
        "percentage": c.percentage or 0.0,
        "contact_number": c.contact_number or "",
        "email": c.email or "",
        "website": c.website or "",
        "address": c.address or "",
        "category": c.category or "Standard",
    }


@router.get("", response_model=List[CustomerResponse])
def list_customers(db: Session = Depends(get_db)):
    """Fetch all registered customers."""
    customers = db.query(Customer).order_by(Customer.name.asc()).all()
    return [_customer_to_dict(c) for c in customers]


@router.get("/{customer_id}", response_model=CustomerResponse)
def get_customer(customer_id: int, db: Session = Depends(get_db)):
    """Fetch single customer by ID."""
    c = db.query(Customer).filter(Customer.id == customer_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found")
    return _customer_to_dict(c)


@router.post("", response_model=CustomerResponse)
async def create_customer(req: CustomerCreate, db: Session = Depends(get_db)):
    """Create a new customer."""
    existing = db.query(Customer).filter(Customer.name.ilike(req.name.strip())).first()
    if existing:
        raise HTTPException(status_code=400, detail="Customer with this name already exists")

    new_cust = Customer(
        name=req.name.strip(),
        percentage=req.percentage,
        contact_number=req.contact_number or "",
        email=req.email or "",
        website=req.website or "",
        address=req.address or "",
        category=req.category or "Standard",
    )
    db.add(new_cust)
    db.commit()
    db.refresh(new_cust)

    data = _customer_to_dict(new_cust)
    await ws_manager.broadcast_event("customer", "create", data)
    return data


@router.put("/{customer_id}", response_model=CustomerResponse)
async def update_customer(customer_id: int, req: CustomerUpdate, db: Session = Depends(get_db)):
    """Update customer details."""
    c = db.query(Customer).filter(Customer.id == customer_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found")

    update_data = req.dict(exclude_unset=True)
    for field, val in update_data.items():
        if val is not None:
            setattr(c, field, val)

    db.commit()
    db.refresh(c)

    data = _customer_to_dict(c)
    await ws_manager.broadcast_event("customer", "update", data)
    return data


@router.delete("/{customer_id}")
async def delete_customer(customer_id: int, db: Session = Depends(get_db)):
    """Delete a customer."""
    c = db.query(Customer).filter(Customer.id == customer_id).first()
    if not c:
        raise HTTPException(status_code=404, detail="Customer not found")

    db.delete(c)
    db.commit()
    await ws_manager.broadcast_event("customer", "delete", {"id": customer_id})
    return {"message": f"Customer {customer_id} deleted successfully"}
