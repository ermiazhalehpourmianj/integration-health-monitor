import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

def generate_orders(n=100, start_date="2024-01-01"):
    np.random.seed(42)

    start = datetime.strptime(start_date, "%Y-%m-%d")
    orders = []

    for i in range(n):
        created = start + timedelta(hours=random.randint(0, 240))
        updated = created + timedelta(hours=random.randint(1, 72))

        order = {
            "order_id": f"ORD-{1000+i}",
            "customer": random.choice(["Alpha Inc", "Beta Co", "Gamma Labs", "Delta Printing"]),
            "amount": round(random.uniform(100, 5000), 2),
            "status": random.choice(["Pending", "Processing", "Shipped"]),
            "created_at": created,
            "updated_at": updated
        }
        orders.append(order)

    return pd.DataFrame(orders)

def generate_mismatched_erp(df_sales):
    df_erp = df_sales.copy()

    # introduce mismatches
    for i in range(10):
        idx = random.randint(0, len(df_erp)-1)

        mismatch_type = random.choice(["missing", "amount", "status"])

        if mismatch_type == "missing":
            df_erp.loc[idx, "order_id"] = f"MISSING-{idx}"
        elif mismatch_type == "amount":
            df_erp.loc[idx, "amount"] += random.uniform(10, 200)
        elif mismatch_type == "status":
            df_erp.loc[idx, "status"] = random.choice(["Pending", "Processing", "Shipped"])

    return df_erp

if __name__ == "__main__":
    sales = generate_orders(120)
    erp = generate_mismatched_erp(sales)

    sales.to_csv("sales_orders.csv", index=False)
    erp.to_csv("erp_orders.csv", index=False)

    print("Generated sales_orders.csv and erp_orders.csv")
