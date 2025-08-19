from pydantic_settings import BaseSettings, SettingsConfigDict


class ShopifyConfiguration(BaseSettings):
    store_name: str
    api_key: str
    api_access_token: str
    api_secret: str
    request_timeout_in_second: int = 15

    model_config = SettingsConfigDict(
        env_prefix='SHOPIFY_', env_file='config.sh.example', extra='ignore'
    )


conf = ShopifyConfiguration()
