"""
Basic skeleton of a mitmproxy addon.

Run as follows: mitmproxy -s addon.py
"""
from mitmproxy import ctx

def response(flow):
    # Define the URL you want to target
    target_url = "https://omanyte.dev.backend.kenbi.systems/shift/current"

    # Check if the request URL matches the target URL
    if flow.request.url.startswith(target_url):
        # Load the content from the file
        with open("/Users/matheusgoncalves/shift_raw_response.txt", "r") as file:
            new_body = file.read()

        # Update the response content with the content from the file
        flow.response.content = bytes(new_body, "utf-8")

        #flow.response.status_code = 500

        # Log the modification
        ctx.log.info(f"Replaced response body for {flow.request.url} with content from file.")