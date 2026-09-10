import sqlite3
import os
from datetime import datetime
import json
import requests
import threading
import time

DB_FILE = os.path.join(os.path.dirname(__file__), "crm_database.db")

# Optional: backend API configuration. If set, crm_engine will proxy calls to the FastAPI backend.
BACKEND_API_URL = os.getenv("BACKEND_API_URL")  # e.g. https://api.example.com
BACKEND_API_TOKEN = os.getenv("BACKEND_API_TOKEN")


def get_db():
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    return conn


def _api_headers():
    headers = {"Content-Type": "application/json"}
    if BACKEND_API_TOKEN:
        headers["Authorization"] = f"Bearer {BACKEND_API_TOKEN}"
    return headers


def init_crm_db():
    """Initializes relational tables for the CRM engine."""
    with get_db() as conn:
        cursor = conn.cursor()
        
        # Contacts / Leads
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS contacts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                company_name TEXT NOT NULL,
                primary_contact TEXT,
                email TEXT,
                phone TEXT,
                status TEXT DEFAULT 'New',
                lead_score INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)

        # Sales Pipeline / Deals
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS deals (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                contact_id INTEGER NOT NULL,
                deal_name TEXT NOT NULL,
                deal_value REAL DEFAULT 0.0,
                stage TEXT DEFAULT 'Prospect',
                probability INTEGER DEFAULT 20,
                close_date DATE,
                FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
            )
        """)

        # Interaction Logs
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS interactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                contact_id INTEGER NOT NULL,
                type TEXT NOT NULL, -- Call, Email, Meeting, Note
                summary TEXT NOT NULL,
                logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
            )
        """)

        # Tasks / Reminders
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                contact_id INTEGER,
                title TEXT NOT NULL,
                due_date DATETIME NOT NULL,
                is_completed INTEGER DEFAULT 0,
                FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
            )
        """)
        conn.commit()


# Operations API
def add_contact(company, contact_person, email, phone, status="New"):
    # If BACKEND_API_URL is configured, forward to the backend API
    if BACKEND_API_URL:
        payload = {
            "company_name": company,
            "primary_contact": contact_person,
            "email": email,
            "phone": phone,
            "status": status,
        }
        try:
            resp = requests.post(f"{BACKEND_API_URL.rstrip('/')}/api/v1/crm/contacts", headers=_api_headers(), json=payload, timeout=10)
            resp.raise_for_status()
            return resp.json().get("id") or resp.json().get("contact_id")
        except Exception:
            # On any API failure, fall back to local DB to preserve functionality
            pass

    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO contacts (company_name, primary_contact, email, phone, status) VALUES (?, ?, ?, ?, ?)",
            (company, contact_person, email, phone, status)
        )
        conn.commit()
        return cursor.lastrowid


def log_interaction(contact_id, interaction_type, summary):
    if BACKEND_API_URL:
        payload = {"contact_id": contact_id, "type": interaction_type, "summary": summary}
        try:
            resp = requests.post(f"{BACKEND_API_URL.rstrip('/')}/api/v1/crm/interactions", headers=_api_headers(), json=payload, timeout=10)
            resp.raise_for_status()
            return resp.json()
        except Exception:
            pass

    with get_db() as conn:
        conn.execute(
            "INSERT INTO interactions (contact_id, type, summary) VALUES (?, ?, ?)",
            (contact_id, interaction_type, summary)
        )
        conn.commit()


def fetch_all_contacts():
    if BACKEND_API_URL:
        try:
            resp = requests.get(f"{BACKEND_API_URL.rstrip('/')}/api/v1/crm/contacts", headers=_api_headers(), timeout=10)
            resp.raise_for_status()
            return resp.json()
        except Exception:
            pass

    with get_db() as conn:
        return conn.execute("SELECT * FROM contacts ORDER BY created_at DESC").fetchall()


def fetch_pipeline_metrics():
    """Returns aggregated metrics for dashboard views."""
    if BACKEND_API_URL:
        try:
            resp = requests.get(f"{BACKEND_API_URL.rstrip('/')}/api/v1/crm/metrics", headers=_api_headers(), timeout=10)
            resp.raise_for_status()
            return resp.json()
        except Exception:
            pass

    with get_db() as conn:
        total_value = conn.execute("SELECT SUM(deal_value) FROM deals").fetchone()[0] or 0.0
        active_leads = conn.execute("SELECT COUNT(*) FROM contacts WHERE status != 'Lost'").fetchone()[0]
        pending_tasks = conn.execute("SELECT COUNT(*) FROM tasks WHERE is_completed = 0").fetchone()[0]
        return {
            "total_pipeline_value": total_value,
            "active_leads": active_leads,
            "pending_tasks": pending_tasks
        }


def start_crm_ws_listener(on_event=None):
    """Start a background WebSocket listener to receive CRM events from backend.

    on_event: callable(event_dict) - called when an event is received.
    Returns True if listener started, False otherwise.
    """
    if not BACKEND_API_URL:
        return False

    try:
        from websocket import WebSocketApp
    except Exception:
        # websocket-client not installed
        return False

    # Build WS URL (ws/wss)
    ws_url = BACKEND_API_URL.rstrip('/')
    if ws_url.startswith('https://'):
        ws_url = 'wss://' + ws_url[len('https://'):]
    elif ws_url.startswith('http://'):
        ws_url = 'ws://' + ws_url[len('http://'):]
    ws_url = ws_url + '/ws/crm'

    def _on_message(ws, message):
        try:
            data = json.loads(message)
            if callable(on_event):
                try:
                    on_event(data)
                except Exception:
                    pass
        except Exception:
            pass

    def _on_error(ws, error):
        # Silent for now; UI may log if desired
        return

    def _on_close(ws, close_status_code, close_msg):
        return

    def _run():
        while True:
            try:
                wsapp = WebSocketApp(ws_url, on_message=_on_message, on_error=_on_error, on_close=_on_close)
                wsapp.run_forever()
            except Exception:
                time.sleep(5)

    t = threading.Thread(target=_run, daemon=True)
    t.start()
    return True