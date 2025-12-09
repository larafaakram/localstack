from display import format_response, get_greeting

def lambda_handler(event, context):
    name = event.get("queryStringParameters", {}).get("name", "World")
    greeting = get_greeting(name)
    return format_response(200, {"message": greeting})