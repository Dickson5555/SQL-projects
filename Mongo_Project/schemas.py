from pydantic import BaseModel
from typing import Optional

class Product(BaseModel):
    name: str
    category: str
    price: float
    stock: int
    brand: str
    rating: float
    sales: int

class User(BaseModel):
    username: str
    password: str