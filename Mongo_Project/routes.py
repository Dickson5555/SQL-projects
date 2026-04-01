from fastapi import APIRouter, HTTPException
from database import product_collection, user_collection
from schemas import Product, User
from security import hash_password, verify_password, create_token
from bson import ObjectId

router = APIRouter()

# USER AUTH
@router.post("/register")
def register(user: User):
    user.password = hash_password(user.password)
    user_collection.insert_one(user.dict())
    return {"message": "User created"}

@router.post("/login")
def login(user: User):
    db_user = user_collection.find_one({"username": user.username})
    if not db_user or not verify_password(user.password, db_user["password"]):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    token = create_token({"user": user.username})
    return {"token": token}

# CRUD OPERATIONS

@router.post("/products")
def create_product(product: Product):
    product_collection.insert_one(product.dict())
    return {"message": "Product added"}

@router.get("/products")
def get_products(page: int = 1, limit: int = 5):
    skips = limit * (page - 1)
    products = list(product_collection.find().skip(skips).limit(limit))
    for p in products:
        p["_id"] = str(p["_id"])
    return products

@router.patch("/products/{id}")
def update_product(id: str, data: dict):
    product_collection.update_one({"_id": ObjectId(id)}, {"$set": data})
    return {"message": "Updated"}

@router.delete("/products/{id}")
def delete_product(id: str):
    product_collection.delete_one({"_id": ObjectId(id)})
    return {"message": "Deleted"}


 #ADVANCED QUERIES
@router.get("/products/filter")
def filter_products():
    products = list(product_collection.find({
        "price": {"$gt": 1000, "$lt": 5000}
    }))
    for p in products:
        p["_id"] = str(p["_id"])
    return products


# AGGREGATION

@router.get("/products/stats")
def stats():
    result = list(product_collection.aggregate([
        {"$group": {"_id": None, "avgPrice": {"$avg": "$price"}}}
    ]))
    return result


# BULK INSERT
@router.post("/products/bulk")
def bulk_insert():
    data = [
        {"name": "Phone", "category": "Electronics", "price": 2000, "stock": 20, "brand": "Samsung", "rating": 4.3, "sales": 150},
        {"name": "Laptop", "category": "Electronics", "price": 5000, "stock": 10, "brand": "HP", "rating": 4.5, "sales": 200}
    ]
    product_collection.insert_many(data)
    return {"message": "Bulk insert done"}


