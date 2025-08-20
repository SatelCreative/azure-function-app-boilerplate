from pydantic_settings import BaseSettings, SettingsConfigDict


class MainConfiguration(BaseSettings):
    app_domain: str
    api_key: str

    model_config = SettingsConfigDict(env_file='config.sh.example', extra='ignore')


conf = MainConfiguration()
