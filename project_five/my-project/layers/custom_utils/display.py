import json

def format_response(status_code, data):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(data)
    }

def get_greeting(name):
    return f"Hello, {name}!"