-- ============================================================================
-- BikeStore Inventory Durability Analysis
-- ============================================================================
-- Project: Calculate product durability (in days) for each store
-- Database: BikeSale
-- Author: Hamrah Aval Academy - Data Science Course
-- Description: This query calculates how many days each product will last
--              in each store based on current inventory and sales velocity
-- ============================================================================

USE BikeSale;

/*
FINAL OUTPUT:
    Number of rows: 939 (3 stores × 313 products)
    Columns: 
        - store_id: Store identifier
        - product_id: Product identifier
        - p_durability(day): Number of days the current stock will last
*/

WITH 
-- ============================================================================
-- Step 1: Calculate Total Sales Quantity per Product per Store
-- ============================================================================
-- Purpose: Aggregate the total quantity sold for each product in each store
-- Tables: sales.order_items (sales data), sales.orders (order info)
-- ============================================================================
Sales_Summary AS (
    SELECT 
        o.store_id,                      -- Store where sale occurred
        oi.product_id,                   -- Product that was sold
        SUM(oi.quantity) AS total_sold_qty  -- Total units sold
    FROM sales.order_items oi
    LEFT JOIN sales.orders o 
        ON oi.order_id = o.order_id
    GROUP BY 
        o.store_id, 
        oi.product_id
),

-- ============================================================================
-- Step 2: Calculate Sales Time Interval for Each Product per Store
-- ============================================================================
-- Purpose: Determine the time span between first and last sale
-- This helps calculate the sales velocity (items sold per day)
-- ============================================================================
Sales_Interval AS (
    SELECT 
        o.store_id,
        oi.product_id,
        MIN(o.order_date) AS first_sale_date,  -- Date of first sale
        MAX(o.order_date) AS last_sale_date,   -- Date of last sale
        DATEDIFF(DAY, MIN(o.order_date), MAX(o.order_date)) AS sales_days_diff  -- Days between first and last sale
    FROM sales.order_items oi
    LEFT JOIN sales.orders o 
        ON oi.order_id = o.order_id
    GROUP BY 
        o.store_id, 
        oi.product_id
),

-- ============================================================================
-- Step 3: Calculate Daily Sales Speed (Velocity)
-- ============================================================================
-- Purpose: Compute how many units are sold per day on average
-- Formula: total_sold_qty / sales_days_diff
-- Special case: If sales_days_diff = 0 (all sales on same day), set speed to 0
-- ============================================================================
Sales_Speed AS (
    SELECT 
        ss.store_id,
        ss.product_id,
        ss.total_sold_qty,               -- Total quantity sold
        si.sales_days_diff,              -- Number of days in sales period
        CASE 
            WHEN si.sales_days_diff = 0  -- Handle division by zero
                THEN 0
            ELSE 
                CAST(ss.total_sold_qty AS DECIMAL(10, 2)) / si.sales_days_diff  -- Average daily sales
        END AS daily_sales_speed
    FROM Sales_Summary ss
    LEFT JOIN Sales_Interval si 
        ON ss.store_id = si.store_id 
        AND ss.product_id = si.product_id
),

-- ============================================================================
-- Step 4: Get Current Stock Levels
-- ============================================================================
-- Purpose: Retrieve the current inventory quantity for each product in each store
-- Table: production.stocks (current inventory levels)
-- ============================================================================
Current_Stock AS (
    SELECT 
        store_id,
        product_id,
        quantity AS current_quantity     -- Current stock on hand
    FROM production.stocks
),

-- ============================================================================
-- Step 5: Calculate Product Durability (Days Until Stock Depletion)
-- ============================================================================
-- Purpose: Calculate how many days the current stock will last
-- Formula: current_quantity / daily_sales_speed
-- Special case: If daily_sales_speed = 0 (no sales), return NULL
-- The FLOOR function rounds down to get whole days
-- ============================================================================
Product_Durability AS (
    SELECT 
        cs.store_id,
        cs.product_id,
        CASE 
            WHEN ss.daily_sales_speed = 0 
                THEN NULL  -- No sales history, cannot calculate durability
            ELSE 
                FLOOR(cs.current_quantity / ss.daily_sales_speed)  -- Days until stock runs out
        END AS [p_durability(day)]
    FROM Current_Stock cs
    LEFT JOIN Sales_Speed ss 
        ON cs.store_id = ss.store_id 
        AND cs.product_id = ss.product_id
)

-- ============================================================================
-- Final Output: Product Durability Report
-- ============================================================================
-- Returns: One row per product per store with calculated durability
-- Sorted by: store_id, then product_id for easy reading
-- ============================================================================
SELECT 
    store_id,                  -- Store identifier
    product_id,                -- Product identifier
    [p_durability(day)]       -- Estimated days until stock depletion
FROM Product_Durability
ORDER BY 
    store_id, 
    product_id;

-- ============================================================================
-- END OF QUERY
-- ============================================================================
