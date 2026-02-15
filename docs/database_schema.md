# BikeSale Database Schema

## Overview

The BikeSale database is a relational database for managing a bike retail business with multiple stores. It contains information about products, customers, orders, staff, and inventory.

## Database Structure

The database is organized into **three schemas**:

1. **`production`** - Product and inventory management
2. **`sales`** - Orders and customer transactions
3. **`hr`** - Not used in this project (staff management)

---

## Tables Used in This Project

### 1. `sales.orders`

Stores customer orders placed at different stores.

| Column | Type | Description |
|--------|------|-------------|
| `order_id` | INT (PK) | Unique order identifier |
| `customer_id` | INT (FK) | Customer who placed the order |
| `order_status` | TINYINT | Order status (1=Pending, 2=Processing, 3=Rejected, 4=Completed) |
| `order_date` | DATE | Date when order was placed |
| `required_date` | DATE | Date when customer needs the order |
| `shipped_date` | DATE | Date when order was shipped |
| `store_id` | INT (FK) | Store where order was placed |
| `staff_id` | INT (FK) | Staff member who processed the order |

**Primary Key:** `order_id`  
**Foreign Keys:** 
- `store_id` → `sales.stores(store_id)`
- `customer_id` → `sales.customers(customer_id)`
- `staff_id` → `hr.staff(staff_id)`

---

### 2. `sales.order_items`

Contains details of products in each order (line items).

| Column | Type | Description |
|--------|------|-------------|
| `order_id` | INT (PK, FK) | Links to orders table |
| `item_id` | INT (PK) | Line item number within the order |
| `product_id` | INT (FK) | Product that was ordered |
| `quantity` | INT | Number of units ordered |
| `list_price` | DECIMAL(10,2) | Price per unit |
| `discount` | DECIMAL(4,2) | Discount percentage (0.00 to 1.00) |

**Primary Key:** `(order_id, item_id)`  
**Foreign Keys:**
- `order_id` → `sales.orders(order_id)`
- `product_id` → `production.products(product_id)`

---

### 3. `production.stocks`

Tracks current inventory levels for each product in each store.

| Column | Type | Description |
|--------|------|-------------|
| `store_id` | INT (PK, FK) | Store identifier |
| `product_id` | INT (PK, FK) | Product identifier |
| `quantity` | INT | Current stock quantity |

**Primary Key:** `(store_id, product_id)`  
**Foreign Keys:**
- `store_id` → `sales.stores(store_id)`
- `product_id` → `production.products(product_id)`

---

## Supporting Tables (Not Directly Queried)

### 4. `production.products`

Product catalog information.

| Column | Type | Description |
|--------|------|-------------|
| `product_id` | INT (PK) | Unique product identifier |
| `product_name` | VARCHAR(255) | Product name |
| `brand_id` | INT (FK) | Brand manufacturer |
| `category_id` | INT (FK) | Product category |
| `model_year` | SMALLINT | Model year |
| `list_price` | DECIMAL(10,2) | Retail price |

---

### 5. `sales.stores`

Information about retail store locations.

| Column | Type | Description |
|--------|------|-------------|
| `store_id` | INT (PK) | Unique store identifier |
| `store_name` | VARCHAR(255) | Store name |
| `phone` | VARCHAR(25) | Contact phone |
| `email` | VARCHAR(255) | Contact email |
| `street` | VARCHAR(255) | Street address |
| `city` | VARCHAR(255) | City |
| `state` | VARCHAR(10) | State |
| `zip_code` | VARCHAR(5) | ZIP code |

---

## Entity Relationship Diagram (Conceptual)

```
┌─────────────────┐
│  sales.stores   │
│  (3 stores)     │
└────────┬────────┘
         │
         │ 1:N
         │
┌────────▼────────┐         ┌──────────────────┐
│  sales.orders   │    N:N  │ production.      │
│                 ├─────────┤ products         │
└────────┬────────┘         │ (313 products)   │
         │                  └─────────┬────────┘
         │ 1:N                        │
         │                            │ N:N
┌────────▼────────┐                  │
│ sales.          │                  │
│ order_items     │                  │
│                 │                  │
└─────────────────┘         ┌────────▼────────┐
                            │ production.     │
                            │ stocks          │
                            │ (939 records)   │
                            └─────────────────┘
```

---

## Data Volume

Based on the BikeSale database:

- **Stores:** 3
- **Products:** 313
- **Stock Records:** 939 (3 stores × 313 products)
- **Orders:** Varies (sample database has ~1600 orders)
- **Order Items:** Varies (sample database has ~4700 line items)

---

## Relationships Summary

| Parent Table | Child Table | Relationship | Foreign Key |
|--------------|-------------|--------------|-------------|
| `sales.stores` | `sales.orders` | 1:N | `store_id` |
| `sales.stores` | `production.stocks` | 1:N | `store_id` |
| `production.products` | `production.stocks` | 1:N | `product_id` |
| `production.products` | `sales.order_items` | 1:N | `product_id` |
| `sales.orders` | `sales.order_items` | 1:N | `order_id` |

---

## Key Constraints

### Primary Keys:
- Ensure uniqueness of records
- Auto-increment where applicable (`order_id`, `product_id`, etc.)

### Foreign Keys:
- Maintain referential integrity
- Prevent orphaned records
- Cascade updates/deletes where appropriate

### Check Constraints:
- `quantity >= 0` (cannot have negative stock)
- `list_price > 0` (price must be positive)
- `discount BETWEEN 0 AND 1` (discount is a percentage)

---

## Indexing Strategy

For optimal query performance:

### Indexes on `sales.orders`:
- Clustered index on `order_id` (PK)
- Non-clustered index on `order_date` (for date range queries)
- Non-clustered index on `store_id` (for store-level analysis)

### Indexes on `sales.order_items`:
- Clustered index on `(order_id, item_id)` (composite PK)
- Non-clustered index on `product_id` (for product-level analysis)

### Indexes on `production.stocks`:
- Clustered index on `(store_id, product_id)` (composite PK)

---

## Sample Data

### Example: sales.orders

| order_id | customer_id | order_date | store_id |
|----------|-------------|------------|----------|
| 1        | 259         | 2016-01-01 | 1        |
| 2        | 7           | 2016-01-01 | 2        |
| 3        | 523         | 2016-01-02 | 2        |

### Example: sales.order_items

| order_id | item_id | product_id | quantity |
|----------|---------|------------|----------|
| 1        | 1       | 20         | 1        |
| 1        | 2       | 8          | 2        |
| 2        | 1       | 10         | 1        |

### Example: production.stocks

| store_id | product_id | quantity |
|----------|------------|----------|
| 1        | 1          | 27       |
| 1        | 2          | 5        |
| 2        | 1          | 30       |

---

## Data Types Used

- **INT:** Whole numbers (IDs, quantities)
- **DECIMAL(10,2):** Prices (2 decimal places)
- **DATE:** Calendar dates (order dates)
- **VARCHAR(n):** Variable-length strings (names, addresses)
- **TINYINT:** Small integers (status codes)

---

## Business Rules

1. **One order can have multiple products** (via order_items)
2. **Each product can be in multiple orders** (many-to-many through order_items)
3. **Each store has its own inventory** for each product (stocks table)
4. **Stock quantity must be non-negative** (cannot sell what you don't have)
5. **Orders are placed at a specific store** (store_id in orders)

---

## Notes

- The database uses a **star schema** design with fact tables (orders, order_items) and dimension tables (products, stores)
- **Timestamps** are not included in this simplified version (only dates)
- **Audit fields** (created_at, updated_at) are not present but recommended for production systems
- The schema supports **multi-store inventory management** which is crucial for the durability analysis

---

## SQL Server Specific Features

- Uses **schemas** to organize tables (production, sales, hr)
- Supports **referential integrity** through foreign keys
- Allows **computed columns** (not used here, but available)
- Supports **triggers** for business logic (not implemented in sample)

---

## For This Project

The durability analysis query specifically uses:
- `sales.orders.order_date` to calculate sales period
- `sales.order_items.quantity` to calculate total sales
- `production.stocks.quantity` to get current inventory

The relationship chain is:
```
stocks → products → order_items → orders
```

This allows us to correlate:
- **What we have** (stocks)
- **What we sold** (order_items)
- **When we sold it** (orders.order_date)
