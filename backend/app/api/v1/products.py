from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import Product, Customer
from app.schemas.product import (
    ProductCreate,
    ProductUpdate,
    ProductResponse,
    ProductSearchQuery,
)
from app.ws.manager import ws_manager

router = APIRouter(prefix="/products", tags=["Products"])


def _product_to_dict(p: Product) -> dict:
    return {
        "id": p.id,
        "pump_current": p.pump_current,
        "num_pumps": p.num_pumps,
        "num_vfd": p.num_vfd,
        "bypass": p.bypass or "Without Bypass",
        "panel_type": p.panel_type or "Indoor",
        "panel_size": p.panel_size or "400x300",
        "panel_class": p.panel_class or "Industrial",
        "main_incomer": p.main_incomer or "Yes",
        "olr_required": p.olr_required or "Yes",
        "indicator_light": p.indicator_light or "Yes",
        "price": p.price,
        "category": p.category or "Booster Pump Control Panel",
        "notes": p.notes or "",
    }


@router.get("", response_model=List[ProductResponse])
def list_products(
    category: Optional[str] = Query(None),
    num_pumps: Optional[int] = Query(None),
    num_vfd: Optional[int] = Query(None),
    bypass: Optional[str] = Query(None),
    skip: int = 0,
    limit: int = 1000,
    db: Session = Depends(get_db),
):
    """List all products with optional filtering."""
    query = db.query(Product)
    if category:
        query = query.filter(Product.category == category)
    if num_pumps is not None:
        query = query.filter(Product.num_pumps == num_pumps)
    if num_vfd is not None:
        query = query.filter(Product.num_vfd == num_vfd)
    if bypass:
        query = query.filter(Product.bypass.ilike(f"%{bypass}%"))

    products = query.order_by(Product.id.asc()).offset(skip).limit(limit).all()
    return [_product_to_dict(p) for p in products]


@router.get("/{product_id}", response_model=ProductResponse)
def get_product(product_id: int, db: Session = Depends(get_db)):
    """Fetch single product by ID."""
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")
    return _product_to_dict(p)


@router.post("", response_model=ProductResponse)
async def create_product(req: ProductCreate, db: Session = Depends(get_db)):
    """Create a new product entry."""
    new_prod = Product(
        pump_current=req.pump_current,
        num_pumps=req.num_pumps,
        num_vfd=req.num_vfd,
        bypass=req.bypass,
        panel_type=req.panel_type,
        panel_size=req.panel_size,
        panel_class=req.panel_class,
        main_incomer=req.main_incomer,
        olr_required=req.olr_required,
        indicator_light=req.indicator_light,
        price=req.price,
        category=req.category or "Booster Pump Control Panel",
        notes=req.notes or "",
    )
    db.add(new_prod)
    db.commit()
    db.refresh(new_prod)

    data = _product_to_dict(new_prod)
    await ws_manager.broadcast_event("product", "create", data)
    return data


@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(product_id: int, req: ProductUpdate, db: Session = Depends(get_db)):
    """Update an existing product."""
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")

    update_data = req.dict(exclude_unset=True)
    for field, val in update_data.items():
        if val is not None:
            setattr(p, field, val)

    db.commit()
    db.refresh(p)

    data = _product_to_dict(p)
    await ws_manager.broadcast_event("product", "update", data)
    return data


@router.delete("/{product_id}")
async def delete_product(product_id: int, db: Session = Depends(get_db)):
    """Delete a product by ID."""
    p = db.query(Product).filter(Product.id == product_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Product not found")

    db.delete(p)
    db.commit()
    await ws_manager.broadcast_event("product", "delete", {"id": product_id})
    return {"message": f"Product {product_id} deleted successfully"}


@router.post("/search")
def search_product_price(
    query: ProductSearchQuery,
    customer_id: Optional[int] = None,
    customer_name: Optional[str] = None,
    db: Session = Depends(get_db),
):
    """Searches for a matching panel product configuration and calculates adjusted price."""
    q = db.query(Product)
    if query.category:
        q = q.filter(Product.category == query.category)
    if query.num_pumps is not None:
        q = q.filter(Product.num_pumps == query.num_pumps)
    if query.num_vfd is not None:
        q = q.filter(Product.num_vfd == query.num_vfd)
    if query.pump_current is not None:
        q = q.filter(Product.pump_current >= query.pump_current - 0.05, Product.pump_current <= query.pump_current + 0.05)
    if query.bypass:
        q = q.filter(Product.bypass.ilike(f"%{query.bypass.strip()}%"))
    if query.panel_type:
        q = q.filter(Product.panel_type.ilike(f"%{query.panel_type.strip()}%"))
    if query.panel_size:
        q = q.filter(Product.panel_size.ilike(f"%{query.panel_size.strip()}%"))

    matched = q.first()

    # Calculate customer adjustment
    cust = None
    if customer_id:
        cust = db.query(Customer).filter(Customer.id == customer_id).first()
    elif customer_name:
        cust = db.query(Customer).filter(Customer.name.ilike(customer_name.strip())).first()

    adj_pct = cust.percentage if cust else 0.0

    if matched:
        base_price = matched.price
        final_price = base_price + (base_price * (adj_pct / 100.0))
        return {
            "found": True,
            "product": _product_to_dict(matched),
            "base_price": base_price,
            "final_price": final_price,
            "customer_adjustment_percent": adj_pct,
            "customer_name": cust.name if cust else "Standard",
        }
    else:
        return {
            "found": False,
            "product": None,
            "base_price": 0.0,
            "final_price": 0.0,
            "customer_adjustment_percent": adj_pct,
            "customer_name": cust.name if cust else "Standard",
        }


@router.post("/bulk")
async def bulk_import_products(products: List[ProductCreate], db: Session = Depends(get_db)):
    """Bulk import multiple products (e.g. from CSV upload)."""
    created = []
    for req in products:
        p = Product(
            pump_current=req.pump_current,
            num_pumps=req.num_pumps,
            num_vfd=req.num_vfd,
            bypass=req.bypass,
            panel_type=req.panel_type,
            panel_size=req.panel_size,
            panel_class=req.panel_class,
            main_incomer=req.main_incomer,
            olr_required=req.olr_required,
            indicator_light=req.indicator_light,
            price=req.price,
            category=req.category or "Booster Pump Control Panel",
            notes=req.notes or "",
        )
        db.add(p)
        created.append(p)

    db.commit()
    await ws_manager.broadcast_event("product", "bulk_import", {"count": len(created)})
    return {"message": f"Successfully imported {len(created)} products"}
