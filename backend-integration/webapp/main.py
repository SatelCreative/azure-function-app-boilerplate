import fastapi
from fastapi import Request
from fastapi.templating import Jinja2Templates

from __version__ import __version__
from base_models.service_status import ServiceStatus
from shopify import ShopifyClient
from shopify import conf as shopify_conf

app = fastapi.FastAPI()


@app.get('/health', include_in_schema=False)
async def health():
    return {'status': 'ok'}


templates = Jinja2Templates(directory='webapp/templates')


@app.get('/health/details')
async def get_health_details(request: Request):
    shopify_client = await ShopifyClient.load(shopify_conf.store_name)
    shopify_connection = await shopify_client.test_connection()

    service_list: list[ServiceStatus] = [
        ServiceStatus(
            name='Shopify API Connection: ' + shopify_conf.store_name,
            is_ok=shopify_connection.result,
            speed_ms=int(shopify_connection.elapsed_time.milliseconds),
        ),
    ]
    return templates.TemplateResponse(
        'health_status.html',
        {
            'request': request,
            'service_list': [status.model_dump() for status in service_list],
            'app_name': '{{appName}}',
            'version': __version__,
        },
    )
