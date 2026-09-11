"""
Centralized API Client for Desktop Application
Connects the Tkinter Desktop app to the AWS FastAPI Backend.
Handles JWT authentication, REST CRUD operations, transparent offline fallback,
and background WebSocket synchronization.
"""

import json
import logging
import os
import threading
import time
from typing import Any, Callable, Dict, List, Optional
import requests

logger = logging.getLogger("api_client")

DEFAULT_API_URL = os.getenv("BACKEND_API_URL", "http://127.0.0.1:8000")


class ApiClient:
    _instance = None
    _lock = threading.Lock()

    def __new__(cls, *args, **kwargs):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super().__new__(cls)
                cls._instance._initialized = False
            return cls._instance

    def __init__(self, base_url: Optional[str] = None):
        if self._initialized:
            return
        self.base_url = (base_url or DEFAULT_API_URL).rstrip("/")
        self.access_token: Optional[str] = None
        self.current_user: Optional[Dict[str, Any]] = None
        self._event_callbacks: List[Callable[[Dict[str, Any]], None]] = []
        self._ws_thread: Optional[threading.Thread] = None
        self._ws_running = False
        self._initialized = True

    # -----------------------------------------------------------------------
    # AUTHENTICATION
    # -----------------------------------------------------------------------

    def get_headers(self) -> Dict[str, str]:
        headers = {"Content-Type": "application/json"}
        if self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"
        return headers

    def login(self, username: str, password: str) -> bool:
        """Authenticate user against the centralized AWS/local backend."""
        try:
            url = f"{self.base_url}/api/v1/auth/login"
            resp = requests.post(url, json={"username": username, "password": password}, timeout=6)
            if resp.status_code == 200:
                data = resp.json()
                self.access_token = data.get("access_token")
                self.current_user = data.get("user")
                # Auto-start WebSocket listener for real-time events
                self.start_websocket_listener()
                return True
            return False
        except Exception as e:
            logger.warning(f"API Login error (server might be offline): {e}")
            return False

    def is_online(self) -> bool:
        """Check if backend API server is reachable."""
        try:
            resp = requests.get(f"{self.base_url}/health", timeout=3)
            return resp.status_code == 200
        except Exception:
            return False

    def get_users(self) -> List[Dict[str, Any]]:
        try:
            resp = requests.get(f"{self.base_url}/api/v1/auth/users", headers=self.get_headers(), timeout=5)
            if resp.status_code == 200:
                return resp.json()
        except Exception:
            pass
        return []

    def create_or_update_user(self, user_dict: Dict[str, Any]) -> bool:
        try:
            resp = requests.post(
                f"{self.base_url}/api/v1/auth/users",
                headers=self.get_headers(),
                json=user_dict,
                timeout=5,
            )
            return resp.status_code == 200
        except Exception:
            return False

    def delete_user(self, username: str) -> bool:
        try:
            resp = requests.delete(
                f"{self.base_url}/api/v1/auth/users/{username}",
                headers=self.get_headers(),
                timeout=5,
            )
            return resp.status_code == 200
        except Exception:
            return False

    # -----------------------------------------------------------------------
    # PRODUCTS CRUD
    # -----------------------------------------------------------------------

    def get_products(self, category: Optional[str] = None) -> List[Dict[str, Any]]:
        params = {}
        if category:
            params["category"] = category
        try:
            resp = requests.get(
                f"{self.base_url}/api/v1/products",
                headers=self.get_headers(),
                params=params,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error fetching products: {e}")
        return []

    def create_product(self, product_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.post(
                f"{self.base_url}/api/v1/products",
                headers=self.get_headers(),
                json=product_data,
                timeout=6,
            )
            if resp.status_code in (200, 201):
                return resp.json()
        except Exception as e:
            logger.warning(f"Error creating product: {e}")
        return None

    def update_product(self, product_id: int, product_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.put(
                f"{self.base_url}/api/v1/products/{product_id}",
                headers=self.get_headers(),
                json=product_data,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error updating product: {e}")
        return None

    def delete_product(self, product_id: int) -> bool:
        try:
            resp = requests.delete(
                f"{self.base_url}/api/v1/products/{product_id}",
                headers=self.get_headers(),
                timeout=6,
            )
            return resp.status_code == 200
        except Exception:
            return False

    def search_product_price(self, query: Dict[str, Any], customer_name: Optional[str] = None) -> Optional[Dict[str, Any]]:
        try:
            params = {}
            if customer_name:
                params["customer_name"] = customer_name
            resp = requests.post(
                f"{self.base_url}/api/v1/products/search",
                headers=self.get_headers(),
                params=params,
                json=query,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error in search_product_price: {e}")
        return None

    # -----------------------------------------------------------------------
    # CUSTOMERS CRUD
    # -----------------------------------------------------------------------

    def get_customers(self) -> List[Dict[str, Any]]:
        try:
            resp = requests.get(
                f"{self.base_url}/api/v1/customers",
                headers=self.get_headers(),
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error fetching customers: {e}")
        return []

    def create_customer(self, customer_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.post(
                f"{self.base_url}/api/v1/customers",
                headers=self.get_headers(),
                json=customer_data,
                timeout=6,
            )
            if resp.status_code in (200, 201):
                return resp.json()
        except Exception as e:
            logger.warning(f"Error creating customer: {e}")
        return None

    def update_customer(self, customer_id: int, customer_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.put(
                f"{self.base_url}/api/v1/customers/{customer_id}",
                headers=self.get_headers(),
                json=customer_data,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error updating customer: {e}")
        return None

    def delete_customer(self, customer_id: int) -> bool:
        try:
            resp = requests.delete(
                f"{self.base_url}/api/v1/customers/{customer_id}",
                headers=self.get_headers(),
                timeout=6,
            )
            return resp.status_code == 200
        except Exception:
            return False

    # -----------------------------------------------------------------------
    # CRM CRUD
    # -----------------------------------------------------------------------

    def get_crm_contacts(self) -> List[Dict[str, Any]]:
        try:
            resp = requests.get(
                f"{self.base_url}/api/v1/crm/contacts",
                headers=self.get_headers(),
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error fetching CRM contacts: {e}")
        return []

    def create_crm_contact(self, contact_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.post(
                f"{self.base_url}/api/v1/crm/contacts",
                headers=self.get_headers(),
                json=contact_data,
                timeout=6,
            )
            if resp.status_code in (200, 201):
                return resp.json()
        except Exception as e:
            logger.warning(f"Error creating CRM contact: {e}")
        return None

    def update_crm_contact(self, contact_id: int, contact_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.put(
                f"{self.base_url}/api/v1/crm/contacts/{contact_id}",
                headers=self.get_headers(),
                json=contact_data,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error updating CRM contact: {e}")
        return None

    def delete_crm_contact(self, contact_id: int) -> bool:
        try:
            resp = requests.delete(
                f"{self.base_url}/api/v1/crm/contacts/{contact_id}",
                headers=self.get_headers(),
                timeout=6,
            )
            return resp.status_code == 200
        except Exception:
            return False

    def get_crm_metrics(self) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.get(
                f"{self.base_url}/api/v1/crm/metrics",
                headers=self.get_headers(),
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception:
            pass
        return None

    # -----------------------------------------------------------------------
    # INWARD INVOICES & FINANCE CRUD
    # -----------------------------------------------------------------------

    def get_inward_entries(self) -> List[Dict[str, Any]]:
        try:
            resp = requests.get(
                f"{self.base_url}/api/v1/finance/inward",
                headers=self.get_headers(),
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error fetching inward entries: {e}")
        return []

    def create_inward_entry(self, entry_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.post(
                f"{self.base_url}/api/v1/finance/inward",
                headers=self.get_headers(),
                json=entry_data,
                timeout=6,
            )
            if resp.status_code in (200, 201):
                return resp.json()
        except Exception as e:
            logger.warning(f"Error creating inward entry: {e}")
        return None

    def update_inward_entry(self, entry_id: int, entry_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.put(
                f"{self.base_url}/api/v1/finance/inward/{entry_id}",
                headers=self.get_headers(),
                json=entry_data,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception:
            pass
        return None

    def delete_inward_entry(self, entry_id: int) -> bool:
        try:
            resp = requests.delete(
                f"{self.base_url}/api/v1/finance/inward/{entry_id}",
                headers=self.get_headers(),
                timeout=6,
            )
            return resp.status_code == 200
        except Exception:
            return False

    # -----------------------------------------------------------------------
    # WAREHOUSE CRUD
    # -----------------------------------------------------------------------

    def get_warehouse_items(self) -> List[Dict[str, Any]]:
        try:
            resp = requests.get(
                f"{self.base_url}/api/v1/warehouse/items",
                headers=self.get_headers(),
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception as e:
            logger.warning(f"Error fetching warehouse items: {e}")
        return []

    def create_warehouse_item(self, item_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.post(
                f"{self.base_url}/api/v1/warehouse/items",
                headers=self.get_headers(),
                json=item_data,
                timeout=6,
            )
            if resp.status_code in (200, 201):
                return resp.json()
        except Exception as e:
            logger.warning(f"Error creating warehouse item: {e}")
        return None

    def update_warehouse_item(self, item_id: int, item_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        try:
            resp = requests.put(
                f"{self.base_url}/api/v1/warehouse/items/{item_id}",
                headers=self.get_headers(),
                json=item_data,
                timeout=6,
            )
            if resp.status_code == 200:
                return resp.json()
        except Exception:
            pass
        return None

    def delete_warehouse_item(self, item_id: int) -> bool:
        try:
            resp = requests.delete(
                f"{self.base_url}/api/v1/warehouse/items/{item_id}",
                headers=self.get_headers(),
                timeout=6,
            )
            return resp.status_code == 200
        except Exception:
            return False

    # -----------------------------------------------------------------------
    # REAL-TIME WEBSOCKET SUBSCRIPTION
    # -----------------------------------------------------------------------

    def register_event_listener(self, callback: Callable[[Dict[str, Any]], None]):
        """Register a callback for real-time synchronization events."""
        if callback not in self._event_callbacks:
            self._event_callbacks.append(callback)

    def unregister_event_listener(self, callback: Callable[[Dict[str, Any]], None]):
        if callback in self._event_callbacks:
            self._event_callbacks.remove(callback)

    def start_websocket_listener(self):
        """Starts a background thread to listen for real-time changes made by Mobile or other clients."""
        if self._ws_running:
            return

        try:
            import websocket
        except ImportError:
            logger.info("websocket-client not installed. Skipping live WS subscription.")
            return

        ws_url = self.base_url.replace("https://", "wss://").replace("http://", "ws://") + "/ws/events"

        def _on_message(ws, message):
            try:
                event_data = json.loads(message)
                for cb in list(self._event_callbacks):
                    try:
                        cb(event_data)
                    except Exception as err:
                        logger.warning(f"Error in event callback: {err}")
            except Exception:
                pass

        def _on_error(ws, error):
            pass

        def _on_close(ws, close_status, close_msg):
            pass

        def _run():
            self._ws_running = True
            while self._ws_running:
                try:
                    wsapp = websocket.WebSocketApp(
                        ws_url,
                        on_message=_on_message,
                        on_error=_on_error,
                        on_close=_on_close,
                    )
                    wsapp.run_forever()
                except Exception:
                    time.sleep(5)

        self._ws_thread = threading.Thread(target=_run, daemon=True)
        self._ws_thread.start()


# Global shared client instance
api_client = ApiClient()
