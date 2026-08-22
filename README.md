# BikeStore Inventory Durability Analysis

SQL-based inventory management system to calculate product durability (days until stock depletion) for a bike retail business.

**Course:** Database - Hamrah Aval Academy  
**Database:** Microsoft SQL Server (BikeSale)

---

## 📊 Project Overview

This project analyzes the **BikeStore** database to calculate how long the current inventory will last for each product in each store, based on historical sales velocity. The analysis helps store managers:

- **Predict when to reorder** products
- **Identify slow-moving items** (high durability = low sales)
- **Optimize inventory levels** across multiple stores
- **Prevent stockouts** for popular items

## 🎯 Business Problem

The BikeStore chain (3 stores, 313 products) needs to:
1. Know how many days their current stock will last
2. Identify products that need immediate restocking
3. Compare inventory durability across stores
4. Make data-driven purchasing decisions

## 📁 Project Structure

```
BikeSale-Inventory-Analysis-SQL/
├── data/
│   └── BikeSale.sql                    # Database schema and sample data
├── queries/
│   ├── product_durability_analysis.sql # Main analysis query (commented)
|   └── product_durability_analysis_Persian-comment.sql # Main analysis query (Persiancommented)   
├── docs/
│   ├── project_requirements.png        # Project specifications (Persian)
│   └── database_schema.md              # Database structure documentation
├── README.md                           # This file
└── LICENSE
```

## 🗄️ Database Schema

The project uses the **BikeSale** database with the following key tables:

### Tables Used:

1. **`sales.orders`**
   - `order_id`: Unique order identifier
   - `store_id`: Store where order was placed
   - `order_date`: Date of the order

2. **`sales.order_items`**
   - `order_id`: Links to orders table
   - `product_id`: Product sold
   - `quantity`: Number of units sold

3. **`production.stocks`**
   - `store_id`: Store identifier
   - `product_id`: Product identifier
   - `quantity`: Current inventory level

## 🔍 Analysis Methodology

The query follows a **5-step CTE (Common Table Expression)** approach:

### Step 1: Sales Summary
Calculate total quantity sold for each product in each store.

```sql
Total Sales = SUM(quantity) per product per store
```

### Step 2: Sales Interval
Determine the time span between first and last sale.

```sql
Sales Period = DATEDIFF(first_sale_date, last_sale_date)
```

### Step 3: Sales Speed (Velocity)
Calculate average daily sales rate.

```sql
Daily Sales Speed = Total Sold Quantity / Sales Days
```

### Step 4: Current Stock
Retrieve current inventory levels from the stocks table.

### Step 5: Product Durability
Calculate how many days the current stock will last.

```sql
Durability (days) = Current Stock / Daily Sales Speed
```

## 📈 Output Format

The query produces **939 rows** (3 stores × 313 products):

| Column | Type | Description |
|--------|------|-------------|
| `store_id` | INT | Store identifier (1, 2, or 3) |
| `product_id` | INT | Product identifier |
| `p_durability(day)` | INT | Days until stock runs out (NULL if no sales history) |

### Sample Output:

| store_id | product_id | p_durability(day) |
|----------|------------|-------------------|
| 1        | 1          | 45                |
| 1        | 2          | NULL              |
| 1        | 3          | 12                |
| 2        | 1          | 30                |
| 2        | 2          | 8                 |

**Interpretation:**
- **45 days**: Plenty of stock, low priority for reorder
- **NULL**: No sales history, cannot calculate
- **12 days**: Moderate stock level
- **8 days**: Low stock, consider reordering soon

## 🚀 How to Use

### Prerequisites:
- Microsoft SQL Server 2016 or later
- BikeSale database installed
- SQL Server Management Studio (SSMS) or Azure Data Studio

### Steps:

1. **Restore the Database:**
   ```sql
   -- Run BikeSale.sql to create and populate the database
   ```

2. **Execute the Analysis:**
   ```sql
   -- Open product_durability_analysis.sql in SSMS
   -- Execute the query (F5)
   ```

3. **Interpret Results:**
   - Products with **low durability** (<14 days) need immediate attention
   - Products with **NULL** durability have no sales history
   - Products with **high durability** (>90 days) might be overstocked
 

## 🎓 SQL Concepts Covered

- **Common Table Expressions (CTEs)**
- **Window Functions** (implicit in aggregations)
- **Date Functions** (DATEDIFF, MIN, MAX)
- **Aggregate Functions** (SUM, COUNT)
- **CASE Statements** for conditional logic
- **Type Casting** (DECIMAL conversion)
- **NULL Handling**
- **JOIN Operations** (LEFT JOIN)

## 📝 Notes

- **Durability = NULL** means the product has no sales history
- Sales speed is calculated over the **entire sales period**, not recent period
- Consider using a **rolling window** (e.g., last 30 days) for more accurate predictions
- The query assumes **consistent sales patterns** (no seasonality adjustment)


**Hamrah Aval Academy** - Database Course Project  
