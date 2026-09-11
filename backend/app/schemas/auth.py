from typing import Dict, Optional, Any
from pydantic import BaseModel, Field


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: Dict[str, Any]


class UserBase(BaseModel):
    username: str
    full_name: Optional[str] = ""
    mobile_number: Optional[str] = ""
    designation: Optional[str] = ""
    role: Optional[str] = "User"
    account_status: Optional[str] = "Active"
    permissions: Optional[Dict[str, bool]] = None


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    mobile_number: Optional[str] = None
    designation: Optional[str] = None
    role: Optional[str] = None
    account_status: Optional[str] = None
    password: Optional[str] = None
    permissions: Optional[Dict[str, bool]] = None


class UserResponse(UserBase):
    id: int

    class Config:
        from_attributes = True
