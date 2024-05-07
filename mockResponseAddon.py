#Usage: mitmproxy -s mockResponseAddon.py --set url="url" --set statuscode=200 --set path="path"

from mitmproxy import ctx
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class MockResponse:
    def load(self, loader):
        loader.add_option(
            name="url",
            typespec=Optional[str],
            default=None,
            help="Url to mock",
        )
        loader.add_option(
            name="path",
            typespec=Optional[str],
            default=None,
            help="path for mock response",
        )
        loader.add_option(
            name="statuscode",
            typespec=Optional[int],
            default=None,
            help="status code to mock",
        )

    def response(self, flow):
        # Define the URL you want to target
        target_url = str(ctx.options.url) if ctx.options.url is not None else None
        path = str(ctx.options.path) if ctx.options.path is not None else None
        statusCode = int(ctx.options.statuscode) if ctx.options.statuscode is not None else None
        
        isMatchingUrl = flow.request.url.find(target_url) >= 0
        

        if(path is not None):
            if isMatchingUrl:
                with open(path, "r") as file:
                    new_body = file.read()
                    flow.response.content = bytes(new_body, "utf-8")
            
        if(statusCode is not None):
            if isMatchingUrl:
                flow.response.status_code = statusCode
        
        
addons = [MockResponse()]