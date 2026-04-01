import random
from pymongo import MongoClient

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017")
db = client["inventory_db"]
collection = db["products"]

names = ["Laptop", "Phone", "Tablet", "Headphones", "Camera", "Monitor"]
brands = ["Samsung", "Apple", "HP", "Dell", "Sony", "LG"]
categories = ["Electronics", "Accessories", "Computing"]

products = []

for i in range(1000):
    product = {
        "name": random.choice(names),
        "category": random.choice(categories),
        "price": round(random.uniform(500, 10000), 2),
        "stock": random.randint(1, 100),
        "brand": random.choice(brands),
        "rating": round(random.uniform(1, 5), 1),
        "sales": random.randint(0, 500)
    }
    products.append(product)

collection.insert_many(products)

print("✅ 1000 products inserted successfully!")