from fastapi import FastAPI
from mangum import Mangum

from app.endpoints import router

app = FastAPI()

# Include routers
app.include_router(router)

# This is the entry point for AWS Lambda
handler = Mangum(app)
