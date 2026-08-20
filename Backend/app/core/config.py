from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str = ""
    redis_url: str = ""
    firebase_project_id: str = ""
    google_application_credentials: str = ""
    cors_origins: str = ""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
