# main_function/__init__.py

import azure.functions as func
from .health_function import health
from .function_app import http_trigger_download_report

def main(req: func.HttpRequest) -> func.HttpResponse:
    path = req.route_params.get('path')

    if path == "health":
        return health(req)
    elif path == "http_trigger_download_report":
        return http_trigger_download_report(req)
    else:
        return func.HttpResponse("Endpoint not found", status_code=404)
