"""Contact-form handler.

Invoked via a Lambda Function URL from the CloudFront frontends. Accepts a JSON
POST body with the fields:

    site         required - key into the SITES config below
    name         required
    email        required - must be a valid address (used as Reply-To)
    phone        optional
    departure_point  required - selected departure location / vessel
    start_date   optional - YYYY-MM-DD; the single date, or range start
    end_date     optional - YYYY-MM-DD; range end (requires start_date)
    description  required - the message body

It validates the payload and relays the message to the site's recipients using
SES. Configuration is injected by Terraform through environment variables:

    SITES  JSON object: { "<site>": { "sender", "recipients", "subject" } }

CORS is handled entirely by the Function URL configuration, not in this code.
"""

import json
import os
import re

import boto3
from botocore.exceptions import ClientError

ses = boto3.client("sesv2")

SITES = json.loads(os.environ.get("SITES", "{}"))

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")  # YYYY-MM-DD
MAX_MESSAGE_LEN = 5000


def _response(status, body):
    # CORS headers are intentionally NOT set here. They are owned by the Lambda
    # Function URL's `cors` configuration (see aws/lambda/main.tf). Returning
    # them from the function too would produce duplicate Access-Control-Allow-*
    # headers, which browsers reject (the request succeeds but fetch() throws).
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }


def handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method", "POST")

    # Preflight (OPTIONS) is handled by the Function URL CORS layer without
    # invoking this function, so we only need to handle POST.
    if method != "POST":
        return _response(405, {"error": "Method not allowed"})

    try:
        payload = json.loads(event.get("body") or "{}")
    except (json.JSONDecodeError, TypeError):
        return _response(400, {"error": "Invalid JSON body"})

    site = SITES.get(payload.get("site"))
    if not site:
        return _response(400, {"error": "Unknown site"})

    name = (payload.get("name") or "").strip()
    email = (payload.get("email") or "").strip()
    phone = (payload.get("phone") or "").strip()  # optional
    departure_point = (payload.get("departure_point") or "").strip()
    start_date = (payload.get("start_date") or "").strip()  # optional
    end_date = (payload.get("end_date") or "").strip()  # optional (range)
    description = (payload.get("description") or "").strip()

    if not name or not description:
        return _response(400, {"error": "Name and description are required"})
    if not departure_point:
        return _response(400, {"error": "A departure point is required"})
    if not EMAIL_RE.match(email):
        return _response(400, {"error": "A valid email address is required"})
    if len(description) > MAX_MESSAGE_LEN:
        return _response(400, {"error": "Description is too long"})
    for value in (start_date, end_date):
        if value and not DATE_RE.match(value):
            return _response(400, {"error": "Dates must be in YYYY-MM-DD format"})
    if end_date and not start_date:
        return _response(400, {"error": "An end date requires a start date"})

    # Single date, a range, or none at all.
    if start_date and end_date and end_date != start_date:
        dates = f"{start_date} to {end_date}"
    elif start_date:
        dates = start_date
    else:
        dates = "N/A"

    subject = site.get("subject", "New contact form submission")
    body_text = (
        f"Name: {name}\n"
        f"Email: {email}\n"
        f"Phone: {phone or 'N/A'}\n"
        f"Departure Point: {departure_point}\n"
        f"Date(s): {dates}\n\n"
        f"{description}\n"
    )

    try:
        ses.send_email(
            FromEmailAddress=site["sender"],
            Destination={"ToAddresses": site["recipients"]},
            ReplyToAddresses=[email],
            Content={
                "Simple": {
                    "Subject": {"Data": subject, "Charset": "UTF-8"},
                    "Body": {"Text": {"Data": body_text, "Charset": "UTF-8"}},
                }
            },
        )
    except ClientError as exc:
        print(f"SES send failed: {exc}")
        return _response(502, {"error": "Failed to send message"})

    return _response(200, {"ok": True})
