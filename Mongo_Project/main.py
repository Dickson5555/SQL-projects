from fastapi import FastAPI
from routes import router

app = FastAPI(title="Inventory Management API")

app.include_router(router)