import json
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.db.database import engine, Base, SessionLocal
from app.db.models import User
from app.core.security import hash_password
from app.ws.manager import ws_manager

# API v1 routers
from app.api.v1.auth import router as auth_router
from app.api.v1.products import router as products_router
from app.api.v1.customers import router as customers_router
from app.api.v1.crm import router as crm_router
from app.api.v1.warehouse import router as warehouse_router
from app.api.v1.finance import router as finance_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("saark_api")


def ensure_default_admin():
    """Seeds the default admin user if no users exist in the database."""
    db = SessionLocal()
    try:
        admin = db.query(User).filter(User.username == "admin").first()
        if not admin:
            logger.info("Seeding default master admin account...")
            default_permissions = {
                "allow_price": True,
                "allow_material": True,
                "allow_crm": True,
                "allow_sales": True,
                "allow_production": True,
                "allow_project_management": True,
                "allow_qc_qa": True,
                "allow_panel_mfg": True,
                "allow_accounts": True,
                "allow_hr": True,
                "allow_attendance": True,
                "allow_purchase": True,
                "allow_stores": True,
                "allow_maintenance": True,
                "allow_rnd": True,
                "allow_asset_management": True,
                "allow_ehs": True,
                "allow_pos_ecommerce": True,
                "allow_it": True,
                "allow_customer_service": True,
                "allow_legal": True,
                "allow_admin_dept": True,
                "allow_supply_chain": True,
                "allow_admin": True,
            }
            admin_user = User(
                username="admin",
                password_hash=hash_password("admin123"),
                full_name="System Administrator",
                mobile_number="",
                designation="Managing Director",
                role="Admin",
                account_status="Active",
                permissions=json.dumps(default_permissions),
            )
            db.add(admin_user)
            db.commit()
            logger.info("Default admin created successfully.")
    except Exception as e:
        logger.error(f"Error checking/seeding default admin: {e}")
    finally:
        db.close()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Initializing centralized database schema...")
    Base.metadata.create_all(bind=engine)
    ensure_default_admin()
    logger.info("Saark API is ready to accept connections.")
    yield
    # Shutdown
    logger.info("Shutting down Saark API...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Centralized REST and WebSocket API for Desktop & Flutter Mobile synchronization.",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS Configuration
origins = [origin.strip() for origin in settings.CORS_ORIGINS.split(",") if origin.strip()]
if "*" in origins or not origins:
    allow_origins = ["*"]
else:
    allow_origins = origins

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API Routers
app.include_router(auth_router, prefix=settings.API_V1_STR)
app.include_router(products_router, prefix=settings.API_V1_STR)
app.include_router(customers_router, prefix=settings.API_V1_STR)
app.include_router(crm_router, prefix=settings.API_V1_STR)
app.include_router(warehouse_router, prefix=settings.API_V1_STR)
app.include_router(finance_router, prefix=settings.API_V1_STR)


@app.get("/")
def root():
    return {
        "system": "Saark Operating System Cloud API",
        "status": "online",
        "docs": "/docs",
        "api_v1": settings.API_V1_STR,
    }


@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "saark-backend-api"}


@app.websocket("/ws/events")
async def websocket_endpoint(websocket: WebSocket):
    """Real-time bi-directional event stream for Desktop & Mobile apps."""
    await ws_manager.connect(websocket)
    try:
        while True:
            # Keep connection alive and accept incoming messages from clients
            data = await websocket.receive_text()
            try:
                msg = json.loads(data)
                # If client requests a broadcast
                if "entity" in msg and "action" in msg:
                    await ws_manager.broadcast_event(msg["entity"], msg["action"], msg.get("data", {}))
            except Exception:
                pass
    except WebSocketDisconnect:
        ws_manager.disconnect(websocket)
    except Exception:
        ws_manager.disconnect(websocket)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
