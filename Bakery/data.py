import csv
import random
from datetime import datetime, timedelta

def generate_mock_sales_data():
    bread_types = {
        "Barbari": 15000,
        "Sangak": 10000,
        "Taftoon": 12000
    }
    
    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)
    
    sales_data = []
    current_date = start_date
    
    while current_date <= end_date:
        weekday = current_date.weekday()
        
        if weekday in [4, 5]:
            day_factor = 1.5
        elif weekday == 2:
            day_factor = 0.7
        else:
            day_factor = 1.0
        
        for bread_name, price in bread_types.items():
            if bread_name == "Barbari":
                base_quantity = random.randint(15, 30)
            elif bread_name == "Sangak":
                base_quantity = random.randint(10, 20)
            else:
                base_quantity = random.randint(5, 15)
            
            final_quantity = int(base_quantity * day_factor) + random.randint(-3, 3)
            quantity = max(0, final_quantity)
            
            if quantity > 0:
                sales_data.append({
                    'date': current_date.strftime('%Y-%m-%d'),
                    'bread_name': bread_name,
                    'quantity': quantity,
                    'unit_price': price,
                    'total_price': quantity * price,
                    'bakery_name': random.choice(['Barakat Bakery', 'Sangak Traditional', 'Taftoon Pars']),
                    'day_of_week': current_date.strftime('%A')
                })
        
        current_date += timedelta(days=1)
    
    return sales_data

def save_to_csv(data, filename='bakery_sales_data.csv'):
    if not data:
        print("❌ No data to save")
        return
    
    fieldnames = ['date', 'bread_name', 'quantity', 'unit_price', 'total_price', 'bakery_name', 'day_of_week']
    
    try:
        with open(filename, 'w', newline='', encoding='utf-8-sig') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            
            for row in data:
                writer.writerow(row)
        
        print(f"✅ File created successfully: {filename}")
        print(f"📊 Total records: {len(data)}")
        
    except Exception as e:
        print(f"❌ Error saving file: {e}")

if __name__ == "__main__":
    print("🔄 Generating mock data...")
    data = generate_mock_sales_data()
    save_to_csv(data, 'bakery_sales_data.csv')
    print("✅ Done!")