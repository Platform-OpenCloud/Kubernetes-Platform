from pydantic import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "mysql+aiomysql://admin:root@localhost:3306/admin"
    SECRET_KEY: str

    class Config:
        env_file = ".env"


settings = Settings()
