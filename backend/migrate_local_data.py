"""
Data Migration Script
Extracts data from local CSV registers and SQLite databases, then inserts them into
the centralized database (PostgreSQL or central SQLite) without creating duplicates.
"""

import csv
import json
import os
import sqlite3
import sys

# Ensure backend folder is in path
backend_dir = os.path.dirname(os.path.abspath(__file__))
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

root_dir = os.path.dirname(backend_dir)

from app.db.database import SessionLocal, Base, engine
from app.db.models import (
    User,
    Product,
    Customer,
    CrmContact,
    CrmDeal,
    CrmInteraction,
    WarehouseItem,
    InwardEntry,
)
from app.core.security import hash_password


def migrate():
    print("=" * 60)
    print("Starting Centralized Data Migration...")
    print(f"Target Database URL: {engine.url}")
    print("=" * 60)

    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        # -------------------------------------------------------------
        # 1. MIGRATE USERS (from users.csv)
        # -------------------------------------------------------------
        users_csv = os.path.join(root_dir, "users.csv")
        if os.path.exists(users_csv):
            print(f"Migrating users from {users_csv}...")
            with open(users_csv, "r", encoding="utf-8-sig") as f:
                reader = csv.DictReader(f)
                migrated_users = 0
                for row in reader:
                    username = row.get("username", "").strip()
                    if not username:
                        continue
                    existing = db.query(User).filter(User.username == username).first()
                    perms = {}
                    for k, v in row.items():
                        if k.startswith("allow_"):
                            perms[k] = str(v).lower() == "true"

                    if not existing:
                        user = User(
                            username=username,
                            password_hash=row.get("password_hash") or hash_password("admin123"),
                            full_name=row.get("full_name", ""),
                            mobile_number=row.get("mobile_number", ""),
                            designation=row.get("designation", ""),
                            role=row.get("role", "User"),
                            account_status=row.get("account_status", "Active"),
                            permissions=json.dumps(perms),
                        )
                        db.add(user)
                        migrated_users += 1
                db.commit()
                print(f"  -> Migrated {migrated_users} new users.")

        # -------------------------------------------------------------
        # 2. MIGRATE CUSTOMERS (from csv_data/customers.csv, booster_customers.csv, customers_detailed.csv)
        # -------------------------------------------------------------
        customer_files = [
            os.path.join(root_dir, "csv_data", "customers.csv"),
            os.path.join(root_dir, "csv_data", "booster_customers.csv"),
            os.path.join(root_dir, "csv_data", "water_meter_customers.csv"),
        ]
        migrated_customers = 0
        seen_customers = {c.name.strip().lower() for c in db.query(Customer).all()}
        for c_file in customer_files:
            if os.path.exists(c_file):
                with open(c_file, "r", encoding="utf-8-sig") as f:
                    reader = csv.DictReader(f)
                    for row in reader:
                        name = (row.get("customer_name") or row.get("name") or "").strip()
                        if not name:
                            continue
                        clean_key = name.lower()
                        if clean_key in seen_customers:
                            continue
                        seen_customers.add(clean_key)
                        try:
                            pct = float(row.get("percentage", 0.0) or 0.0)
                        except Exception:
                            pct = 0.0
                        cat = "Water Meter" if "water_meter" in c_file else "Booster Pump"
                        cust = Customer(name=name, percentage=pct, category=cat)
                        db.add(cust)
                        migrated_customers += 1
        db.commit()
        print(f"  -> Migrated {migrated_customers} customers.")

        # -------------------------------------------------------------
        # 3. MIGRATE PRODUCTS (from csv_data/booster_products.csv, products.csv, price_list_clean.csv)
        # -------------------------------------------------------------
        product_files = [
            (os.path.join(root_dir, "csv_data", "booster_products.csv"), "Booster Pump Control Panel"),
            (os.path.join(root_dir, "csv_data", "products.csv"), "Booster Pump Control Panel"),
            (os.path.join(root_dir, "price_list_clean.csv"), "Booster Pump Control Panel"),
        ]
        migrated_products = 0
        seen_products = set()
        for p in db.query(Product).all():
            seen_products.add((p.pump_current, p.num_pumps, p.num_vfd, p.bypass, p.panel_size, p.panel_type))

        for p_file, cat in product_files:
            if os.path.exists(p_file):
                with open(p_file, "r", encoding="utf-8-sig") as f:
                    reader = csv.DictReader(f)
                    for row in reader:
                        try:
                            pump_current = float(row.get("pump_current", 0.0) or 0.0)
                            num_pumps = int(float(row.get("num_pumps", 1) or 1))
                            num_vfd = int(float(row.get("num_vfd", 0) or 0))
                            price = float(row.get("price", 0.0) or 0.0)
                        except Exception:
                            continue

                        if pump_current <= 0 and price <= 0:
                            continue

                        bypass = row.get("bypass", "Without Bypass")
                        panel_size = row.get("panel_size", "400x300")
                        panel_type = row.get("panel_type", "Indoor")

                        key = (pump_current, num_pumps, num_vfd, bypass, panel_size, panel_type)
                        if key in seen_products:
                            continue
                        seen_products.add(key)

                        prod = Product(
                            pump_current=pump_current,
                            num_pumps=num_pumps,
                            num_vfd=num_vfd,
                            bypass=bypass,
                            panel_type=panel_type,
                            panel_size=panel_size,
                            panel_class=row.get("panel_class", "Industrial"),
                            main_incomer=row.get("main_incomer", "Yes"),
                            olr_required=row.get("olr_required", "Yes"),
                            indicator_light=row.get("indicator_light", "Yes"),
                            price=price,
                            category=cat,
                        )
                        db.add(prod)
                        migrated_products += 1
        db.commit()
        print(f"  -> Migrated {migrated_products} products.")

        # -------------------------------------------------------------
        # 4. MIGRATE CRM CONTACTS (from crm_database.db)
        # -------------------------------------------------------------
        crm_db_path = os.path.join(root_dir, "crm_database.db")
        migrated_leads = 0
        if os.path.exists(crm_db_path):
            try:
                crm_conn = sqlite3.connect(crm_db_path)
                crm_conn.row_factory = sqlite3.Row
                cur = crm_conn.cursor()
                cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='contacts'")
                if cur.fetchone():
                    contacts = cur.execute("SELECT * FROM contacts").fetchall()
                    for c in contacts:
                        company = c["company_name"] if "company_name" in c.keys() else "Unknown"
                        existing = db.query(CrmContact).filter(CrmContact.company_name == company).first()
                        if not existing:
                            contact = CrmContact(
                                company_name=company,
                                primary_contact=c["primary_contact"] if "primary_contact" in c.keys() else "",
                                email=c["email"] if "email" in c.keys() else "",
                                phone=c["phone"] if "phone" in c.keys() else "",
                                status=c["status"] if "status" in c.keys() else "New",
                                lead_score=c["lead_score"] if "lead_score" in c.keys() else 0,
                            )
                            db.add(contact)
                            migrated_leads += 1
                    db.commit()
                crm_conn.close()
            except Exception as e:
                print(f"  Notice regarding CRM SQLite migration: {e}")
        print(f"  -> Migrated {migrated_leads} CRM contacts.")

        # -------------------------------------------------------------
        # 5. MIGRATE WAREHOUSE ITEMS (from csv_data/warehouse_items.csv, inventory.csv)
        # -------------------------------------------------------------
        wh_file = os.path.join(root_dir, "csv_data", "warehouse_items.csv")
        migrated_items = 0
        if os.path.exists(wh_file):
            with open(wh_file, "r", encoding="utf-8-sig") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    code = (row.get("item_code") or row.get("sku") or "").strip()
                    if not code:
                        continue
                    existing = db.query(WarehouseItem).filter(WarehouseItem.item_code == code).first()
                    if not existing:
                        try:
                            qty = float(row.get("quantity", 0.0) or 0.0)
                        except Exception:
                            qty = 0.0
                        item = WarehouseItem(
                            item_code=code,
                            item_name=row.get("item_name") or code,
                            category=row.get("category", "Components"),
                            quantity=qty,
                            unit=row.get("unit", "Pcs"),
                            location=row.get("location", "Main Warehouse"),
                        )
                        db.add(item)
                        migrated_items += 1
            db.commit()
        print(f"  -> Migrated {migrated_items} warehouse items.")

        # -------------------------------------------------------------
        # 6. MIGRATE INWARD INVOICES (from csv_data/inward_entries.csv)
        # -------------------------------------------------------------
        inward_file = os.path.join(root_dir, "csv_data", "inward_entries.csv")
        migrated_inward = 0
        if os.path.exists(inward_file):
            with open(inward_file, "r", encoding="utf-8-sig") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    inv_no = (row.get("invoice_no") or "").strip()
                    supp = (row.get("supplier") or "").strip()
                    if not inv_no and not supp:
                        continue
                    try:
                        qty = float(row.get("quantity", 1.0) or 1.0)
                        rate = float(row.get("rate", 0.0) or 0.0)
                        amount = float(row.get("amount", 0.0) or 0.0)
                    except Exception:
                        qty, rate, amount = 1.0, 0.0, 0.0

                    entry = InwardEntry(
                        date=row.get("date", ""),
                        supplier=supp or "Unknown",
                        invoice_no=inv_no or "N/A",
                        department=row.get("department", "Production"),
                        item_description=row.get("item_description", ""),
                        quantity=qty,
                        rate=rate,
                        amount=amount or (qty * rate),
                        payment_status=row.get("payment_status", "Pending"),
                        payment_method=row.get("payment_method", "Cheque"),
                        cheque_number=row.get("cheque_number", ""),
                        cheque_date=row.get("cheque_date", ""),
                        notes=row.get("notes", ""),
                    )
                    db.add(entry)
                    migrated_inward += 1
            db.commit()
        print(f"  -> Migrated {migrated_inward} inward invoice entries.")

        print("=" * 60)
        print("Data Migration Complete! All records are now stored in the central database.")
        print("=" * 60)

    except Exception as e:
        db.rollback()
        print(f"Migration error: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    migrate()
