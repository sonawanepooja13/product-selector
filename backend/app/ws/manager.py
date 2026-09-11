import json
import logging
from typing import List, Dict, Any
from fastapi import WebSocket

logger = logging.getLogger(__name__)


class WebSocketManager:
    """Manages connected clients (Desktop and Mobile) and broadcasts real-time data events."""

    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info(f"WebSocket client connected. Total clients: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            logger.info(f"WebSocket client disconnected. Remaining clients: {len(self.active_connections)}")

    async def broadcast_event(self, entity: str, action: str, data: Dict[str, Any]):
        """Broadcast an event to all connected Desktop and Mobile clients.

        Args:
            entity: 'product', 'customer', 'crm', 'warehouse', 'finance', 'user'
            action: 'create', 'update', 'delete', 'bulk_import'
            data: Payload dictionary describing the affected entity
        """
        payload = json.dumps({
            "entity": entity,
            "action": action,
            "data": data,
        })
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_text(payload)
            except Exception as e:
                logger.warning(f"Error sending message to client: {e}")
                disconnected.append(connection)

        for conn in disconnected:
            self.disconnect(conn)


ws_manager = WebSocketManager()
