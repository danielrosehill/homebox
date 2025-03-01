#!/usr/bin/env python3
"""
Script to generate random tech items in CSV format for Homebox import
"""

import csv
import random
import datetime
import uuid
from faker import Faker

# Initialize Faker
fake = Faker()

# Define the output file
output_file = "test_items.csv"

# Define item categories and their properties
tech_items = [
    {
        "category": "Laptop",
        "manufacturers": ["Dell", "Apple", "Lenovo", "HP", "ASUS", "Microsoft", "Acer", "MSI"],
        "models": ["XPS", "MacBook Pro", "ThinkPad", "Spectre", "ZenBook", "Surface", "Aspire", "Stealth"],
        "price_range": (800, 3000),
        "description": "High-performance laptop for professional use"
    },
    {
        "category": "Monitor",
        "manufacturers": ["LG", "Samsung", "Dell", "ASUS", "BenQ", "Acer", "ViewSonic", "AOC"],
        "models": ["UltraGear", "Odyssey", "UltraSharp", "ProArt", "Zowie", "Predator", "Elite", "Gaming"],
        "price_range": (200, 1500),
        "description": "High-resolution display with accurate color reproduction"
    },
    {
        "category": "Keyboard",
        "manufacturers": ["Logitech", "Corsair", "Razer", "HyperX", "SteelSeries", "Ducky", "Keychron", "GMMK"],
        "models": ["G Pro", "K100", "BlackWidow", "Alloy", "Apex", "One 2", "K8", "Pro"],
        "price_range": (50, 300),
        "description": "Mechanical keyboard with customizable RGB lighting"
    },
    {
        "category": "Mouse",
        "manufacturers": ["Logitech", "Razer", "SteelSeries", "Corsair", "Glorious", "Zowie", "HyperX", "Endgame Gear"],
        "models": ["G Pro", "DeathAdder", "Rival", "Dark Core", "Model O", "EC2", "Pulsefire", "XM1"],
        "price_range": (30, 200),
        "description": "Precision gaming mouse with adjustable DPI"
    },
    {
        "category": "Headphones",
        "manufacturers": ["Sony", "Bose", "Sennheiser", "Audio-Technica", "Beyerdynamic", "JBL", "AKG", "Jabra"],
        "models": ["WH-1000XM5", "QuietComfort", "HD 660S", "ATH-M50x", "DT 990 Pro", "Quantum", "K712 Pro", "Elite"],
        "price_range": (100, 500),
        "description": "Premium audio headphones with noise cancellation"
    },
    {
        "category": "Tablet",
        "manufacturers": ["Apple", "Samsung", "Microsoft", "Lenovo", "Amazon", "Huawei", "Google", "Wacom"],
        "models": ["iPad Pro", "Galaxy Tab", "Surface Pro", "Tab P11", "Fire HD", "MatePad", "Pixel Slate", "Cintiq"],
        "price_range": (200, 1500),
        "description": "Versatile tablet for productivity and entertainment"
    },
    {
        "category": "Smartphone",
        "manufacturers": ["Apple", "Samsung", "Google", "OnePlus", "Xiaomi", "Sony", "Motorola", "Nothing"],
        "models": ["iPhone", "Galaxy S", "Pixel", "10 Pro", "Mi", "Xperia", "Edge", "Phone"],
        "price_range": (400, 1500),
        "description": "Feature-rich smartphone with advanced camera system"
    },
    {
        "category": "Webcam",
        "manufacturers": ["Logitech", "Razer", "Elgato", "AverMedia", "Microsoft", "OBSBOT", "Insta360", "Poly"],
        "models": ["StreamCam", "Kiyo", "Facecam", "PW513", "LifeCam", "Tiny", "Link", "Studio"],
        "price_range": (50, 300),
        "description": "High-definition webcam for video conferencing"
    },
    {
        "category": "Microphone",
        "manufacturers": ["Blue", "Shure", "Audio-Technica", "Rode", "HyperX", "Elgato", "Razer", "Samson"],
        "models": ["Yeti", "SM7B", "AT2020", "NT-USB", "QuadCast", "Wave", "Seiren", "G-Track"],
        "price_range": (50, 400),
        "description": "Professional-grade microphone for streaming and recording"
    },
    {
        "category": "External Drive",
        "manufacturers": ["Western Digital", "Seagate", "Samsung", "SanDisk", "Crucial", "LaCie", "Toshiba", "Kingston"],
        "models": ["My Passport", "Backup Plus", "T7", "Extreme", "X8", "Rugged", "Canvio", "XS2000"],
        "price_range": (80, 400),
        "description": "Portable storage solution with high transfer speeds"
    }
]

# Generate random dates
def random_date(start_year=2020, end_year=2024):
    year = random.randint(start_year, end_year)
    month = random.randint(1, 12)
    day = random.randint(1, 28)  # Avoiding edge cases with month lengths
    return datetime.date(year, month, day)

# Generate random warranty expiry date
def warranty_expiry(purchase_date):
    warranty_years = random.choice([1, 2, 3, 5])
    expiry_date = purchase_date.replace(year=purchase_date.year + warranty_years)
    return expiry_date

# Generate a random item
def generate_item(asset_id):
    item_type = random.choice(tech_items)
    manufacturer = random.choice(item_type["manufacturers"])
    model = random.choice(item_type["models"])
    price = round(random.uniform(item_type["price_range"][0], item_type["price_range"][1]), 2)
    
    purchase_date = random_date()
    has_lifetime_warranty = random.choice([True, False])
    warranty_date = None if has_lifetime_warranty else warranty_expiry(purchase_date)
    
    # 10% chance the item was sold
    is_sold = random.random() < 0.1
    sold_date = random_date(purchase_date.year, 2024) if is_sold else None
    sold_price = round(price * random.uniform(0.5, 1.2), 2) if is_sold else None
    
    return {
        "HB.quantity": random.randint(1, 3),
        "HB.name": f"{manufacturer} {model} {item_type['category']}",
        "HB.asset_id": asset_id,
        "HB.description": item_type["description"],
        "HB.insured": random.choice([True, False]),
        "HB.serial_number": f"SN-{fake.uuid4()[:8].upper()}",
        "HB.model_number": f"{model}-{random.randint(1000, 9999)}",
        "HB.manufacturer": manufacturer,
        "HB.notes": fake.paragraph(nb_sentences=3),
        "HB.purchase_from": fake.company(),
        "HB.purchase_price": price,
        "HB.purchase_time": purchase_date.strftime("%Y-%m-%d"),
        "HB.lifetime_warranty": has_lifetime_warranty,
        "HB.warranty_expires": warranty_date.strftime("%Y-%m-%d") if warranty_date else "",
        "HB.warranty_details": f"{random.choice(['Standard', 'Extended', 'Premium'])} warranty" if not has_lifetime_warranty else "Lifetime warranty",
        "HB.sold_to": fake.name() if is_sold else "",
        "HB.sold_time": sold_date.strftime("%Y-%m-%d") if sold_date else "",
        "HB.sold_price": sold_price if sold_price else "",
        "HB.sold_notes": fake.paragraph(nb_sentences=2) if is_sold else ""
    }

def main():
    # Generate 20 items
    items = []
    for i in range(1, 21):
        asset_id = 1000 + i
        items.append(generate_item(asset_id))
    
    # Write to CSV
    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = items[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        for item in items:
            writer.writerow(item)
    
    print(f"Generated {len(items)} items in {output_file}")

if __name__ == "__main__":
    main()
