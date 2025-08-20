from typing import ClassVar, Optional

from httpx import AsyncClient
from spylib.admin_api import OfflineTokenABC

from .config import conf


class ShopifyClient(OfflineTokenABC):
    """
    The client to make calls to the Shopify Admin APIs
    """

    store_name: str
    access_token: str
    api_version: ClassVar[Optional[str]] = '2025-07'
    client: ClassVar[AsyncClient] = AsyncClient(timeout=conf.request_timeout_in_second)

    @classmethod
    async def load(cls, store_name: str):
        """
        Load the store target and access token to be used from the configuration
        """
        return cls(store_name=store_name, access_token=conf.api_access_token)

    async def save(self):
        pass


shopify_client = ShopifyClient.load(conf.store_name)
