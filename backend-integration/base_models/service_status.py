from pydantic import BaseModel


class ServiceStatus(BaseModel):
    """The connection status of a Service
    Attributes:
        name (str): The name of the service
        is_ok (bool): The current connection status of the service
        speed_ms (int, optional): The response time of the service in micro second, if applicable
    """

    name: str
    is_ok: bool
    speed_ms: int | None = None
