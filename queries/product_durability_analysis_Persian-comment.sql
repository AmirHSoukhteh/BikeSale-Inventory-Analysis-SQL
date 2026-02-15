USE BikeSale;

/*
خروجی نهایی:
    تعداد ردیف: 939 (3 فروشگاه * 313 کالا)
    ستون‌ها: 
        store_id, 
        product_id, 
        p_durability(day)
*/

WITH 
-- 1. مجموع فروش هر کالا در هر فروشگاه
Sales_Summary AS (
    SELECT 
        o.store_id,
        oi.product_id,
        SUM(oi.quantity) AS total_sold_qty
    FROM sales.order_items oi
    LEFT JOIN sales.orders o 
        ON oi.order_id = o.order_id
    GROUP BY 
        o.store_id, 
        oi.product_id
),

-- 2. بازه زمانی فروش هر کالا در هر فروشگاه
Sales_Interval AS (
    SELECT 
        o.store_id,
        oi.product_id,
        MIN(o.order_date) AS first_sale_date,
        MAX(o.order_date) AS last_sale_date,
        DATEDIFF(DAY, MIN(o.order_date), MAX(o.order_date)) AS sales_days_diff
    FROM sales.order_items oi
    LEFT JOIN sales.orders o 
        ON oi.order_id = o.order_id
    GROUP BY 
        o.store_id, 
        oi.product_id
),

-- 3. محاسبه سرعت فروش روزانه
Sales_Speed AS (
    SELECT 
        ss.store_id,
        ss.product_id,
        ss.total_sold_qty,
        si.sales_days_diff,
        CASE 
            WHEN si.sales_days_diff = 0 
                THEN 0
            ELSE 
                CAST(ss.total_sold_qty AS DECIMAL(10, 2)) / si.sales_days_diff
        END AS daily_sales_speed
    FROM Sales_Summary ss
    LEFT JOIN Sales_Interval si 
        ON ss.store_id = si.store_id 
        AND ss.product_id = si.product_id
),

-- 4. موجودی فعلی هر کالا در هر فروشگاه
Current_Stock AS (
    SELECT 
        store_id,
        product_id,
        quantity AS current_quantity
    FROM production.stocks
),

-- 5. محاسبه ماندگاری (روز)
Product_Durability AS (
    SELECT 
        cs.store_id,
        cs.product_id,
        CASE 
            WHEN ss.daily_sales_speed = 0 
                THEN NULL  -- اگر سرعت فروش صفر باشد (فروش نداشته)
            ELSE 
                FLOOR(cs.current_quantity / ss.daily_sales_speed)
        END AS [p_durability(day)]
    FROM Current_Stock cs
    LEFT JOIN Sales_Speed ss 
        ON cs.store_id = ss.store_id 
        AND cs.product_id = ss.product_id
)

-- خروجی نهایی
SELECT 
    store_id,
    product_id,
    [p_durability(day)]
FROM Product_Durability
ORDER BY 
    store_id, 
    product_id;
