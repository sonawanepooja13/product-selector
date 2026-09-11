from datetime import datetime
from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    Boolean,
    DateTime,
    ForeignKey,
    Text,
    Date,
)
from sqlalchemy.orm import relationship
from app.db.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(200), default="")
    mobile_number = Column(String(50), default="")
    designation = Column(String(100), default="")
    role = Column(String(50), default="User")  # Admin, User, Manager
    account_status = Column(String(50), default="Active")  # Active, Inactive, Suspended
    permissions = Column(Text, default="{}")  # JSON string of permission flags
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    pump_current = Column(Float, nullable=False, default=0.0)
    num_pumps = Column(Integer, nullable=False, default=1)
    num_vfd = Column(Integer, nullable=False, default=0)
    bypass = Column(String(50), default="Without Bypass")
    panel_type = Column(String(50), default="Indoor")
    panel_size = Column(String(50), default="400x300")
    panel_class = Column(String(50), default="Industrial")
    main_incomer = Column(String(50), default="Yes")
    olr_required = Column(String(50), default="Yes")
    indicator_light = Column(String(50), default="Yes")
    price = Column(Float, nullable=False, default=0.0)
    category = Column(String(100), default="Booster Pump Control Panel", index=True)
    notes = Column(Text, default="")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Customer(Base):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(200), unique=True, index=True, nullable=False)
    percentage = Column(Float, default=0.0)  # Discount (-) or markup (+) percentage
    contact_number = Column(String(50), default="")
    email = Column(String(150), default="")
    website = Column(String(200), default="")
    address = Column(Text, default="")
    category = Column(String(100), default="Standard")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class CrmContact(Base):
    __tablename__ = "crm_contacts"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    company_name = Column(String(200), nullable=False, index=True)
    primary_contact = Column(String(150), default="")
    email = Column(String(150), default="")
    phone = Column(String(50), default="")
    status = Column(String(50), default="New", index=True)  # New, Qualified, Proposal, Won, Lost
    category = Column(String(100), default="Booster Pump Control Panel")
    estimated_value = Column(Float, default=0.0)
    stage = Column(String(50), default="new")
    notes = Column(Text, default="")
    lead_score = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    deals = relationship("CrmDeal", back_populates="contact", cascade="all, delete-orphan")
    interactions = relationship("CrmInteraction", back_populates="contact", cascade="all, delete-orphan")


class CrmDeal(Base):
    __tablename__ = "crm_deals"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    contact_id = Column(Integer, ForeignKey("crm_contacts.id", ondelete="CASCADE"), nullable=False)
    deal_name = Column(String(200), nullable=False)
    deal_value = Column(Float, default=0.0)
    stage = Column(String(50), default="Prospect")
    probability = Column(Integer, default=20)
    close_date = Column(String(50), default="")
    created_at = Column(DateTime, default=datetime.utcnow)

    contact = relationship("CrmContact", back_populates="deals")


class CrmInteraction(Base):
    __tablename__ = "crm_interactions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    contact_id = Column(Integer, ForeignKey("crm_contacts.id", ondelete="CASCADE"), nullable=False)
    type = Column(String(50), nullable=False)  # Call, Meeting, Email, Note
    summary = Column(Text, nullable=False)
    logged_at = Column(DateTime, default=datetime.utcnow)

    contact = relationship("CrmContact", back_populates="interactions")


class WarehouseItem(Base):
    __tablename__ = "warehouse_items"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    item_code = Column(String(100), unique=True, index=True, nullable=False)
    item_name = Column(String(200), nullable=False)
    category = Column(String(100), default="Components")
    quantity = Column(Float, default=0.0)
    unit = Column(String(50), default="Pcs")
    location = Column(String(100), default="Main Warehouse")
    reorder_level = Column(Float, default=5.0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class InwardEntry(Base):
    __tablename__ = "inward_entries"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    date = Column(String(50), default="")
    supplier = Column(String(200), nullable=False, index=True)
    invoice_no = Column(String(100), nullable=False, index=True)
    department = Column(String(100), default="Production")
    item_description = Column(Text, default="")
    quantity = Column(Float, default=1.0)
    rate = Column(Float, default=0.0)
    amount = Column(Float, default=0.0)
    payment_status = Column(String(50), default="Pending")  # Pending, Partial, Paid
    payment_method = Column(String(50), default="Cheque")
    cheque_number = Column(String(100), default="")
    cheque_date = Column(String(50), default="")
    cheque_photo = Column(String(255), default="")
    notes = Column(Text, default="")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
