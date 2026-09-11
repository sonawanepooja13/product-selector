import json
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.db.models import User
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    decode_access_token,
)
from app.schemas.auth import (
    LoginRequest,
    TokenResponse,
    UserCreate,
    UserUpdate,
    UserResponse,
)
from app.ws.manager import ws_manager

router = APIRouter(prefix="/auth", tags=["Authentication"])


def get_current_user(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db),
) -> User:
    """Dependency to extract and validate the authenticated user from the Authorization header."""
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header missing",
            headers={"WWW-Authenticate": "Bearer"},
        )

    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization scheme. Expected 'Bearer <token>'",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = parts[1]
    payload = decode_access_token(token)
    username = payload.get("sub")
    if not username:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token subject missing",
        )

    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return user


def _user_to_dict(u: User) -> dict:
    perms = {}
    if u.permissions:
        try:
            perms = json.loads(u.permissions) if isinstance(u.permissions, str) else u.permissions
        except Exception:
            perms = {}
    return {
        "id": u.id,
        "username": u.username,
        "full_name": u.full_name or "",
        "mobile_number": u.mobile_number or "",
        "designation": u.designation or "",
        "role": u.role or "User",
        "account_status": u.account_status or "Active",
        "permissions": perms,
    }


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """Authenticate user with username and password."""
    user = db.query(User).filter(User.username == req.username.strip()).first()
    if not user or not verify_password(req.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password",
        )

    if user.account_status and user.account_status.lower() not in ("active", ""):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Account is {user.account_status}. Please contact administrator.",
        )

    token = create_access_token(subject=user.username, claims={"role": user.role})
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=_user_to_dict(user),
    )


@router.get("/me")
def get_me(current_user: User = Depends(get_current_user)):
    """Returns the profile of the currently logged-in user."""
    return _user_to_dict(current_user)


@router.get("/users")
def list_users(db: Session = Depends(get_db)):
    """Lists all users in the system."""
    users = db.query(User).order_by(User.id.asc()).all()
    return [_user_to_dict(u) for u in users]


@router.post("/users")
async def create_or_update_user(req: UserCreate, db: Session = Depends(get_db)):
    """Create a new user or update an existing user."""
    user = db.query(User).filter(User.username == req.username.strip()).first()
    perms_str = json.dumps(req.permissions or {})

    if user:
        user.full_name = req.full_name or user.full_name
        user.mobile_number = req.mobile_number or user.mobile_number
        user.designation = req.designation or user.designation
        user.role = req.role or user.role
        user.account_status = req.account_status or user.account_status
        if req.password:
            user.password_hash = hash_password(req.password)
        if req.permissions is not None:
            user.permissions = perms_str
        db.commit()
        db.refresh(user)
        res = _user_to_dict(user)
        await ws_manager.broadcast_event("user", "update", res)
        return res
    else:
        new_user = User(
            username=req.username.strip(),
            password_hash=hash_password(req.password),
            full_name=req.full_name or "",
            mobile_number=req.mobile_number or "",
            designation=req.designation or "",
            role=req.role or "User",
            account_status=req.account_status or "Active",
            permissions=perms_str,
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        res = _user_to_dict(new_user)
        await ws_manager.broadcast_event("user", "create", res)
        return res


@router.delete("/users/{username}")
async def delete_user(username: str, db: Session = Depends(get_db)):
    """Delete a user account by username."""
    if username.lower() == "admin":
        raise HTTPException(status_code=400, detail="Cannot delete default admin account")

    user = db.query(User).filter(User.username == username).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    await ws_manager.broadcast_event("user", "delete", {"username": username})
    return {"message": f"User {username} deleted successfully"}
