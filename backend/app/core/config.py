import os
from typing import List, Union
from pydantic import AnyHttpUrl, validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "Saark Operating System API"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "saark_production_secret_jwt_key_2026_saarkos"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours

    # Database URL: default sqlite for dev fallback, PostgreSQL on AWS RDS
    DATABASE_URL: str = "sqlite:///./saark_dev.db"

    # AWS S3 & CloudWatch
    AWS_REGION: str = "us-east-1"
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_S3_BUCKET_NAME: str = "saark-product-selector-documents"
    ENABLE_CLOUDWATCH_LOGS: bool = False
    CLOUDWATCH_LOG_GROUP: str = "saark-api-logs"

    # CORS Origins
    CORS_ORIGINS: str = "*"

    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
