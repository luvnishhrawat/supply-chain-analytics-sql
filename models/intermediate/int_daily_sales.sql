-- Model: int_daily_sales
-- Layer: intermediate
-- Description: Daily and MTD sales aggregation at sku-location grain
-- Grain: date, sku_id, location_id

WITH base_sales AS (
    SELECT
        ii.sku_id,
        l.id AS location_id,
        DATE(i.invoice_date) AS invoice_date,
        ii.shipped_quantity
    FROM invoices i
    JOIN invoice_items ii ON ii.invoice_id = i.id
    JOIN channel_orders co ON co.id = i.channel_order_id
    LEFT JOIN locations l ON co.location_id = l.id
    WHERE co.order_id NOT LIKE 'OD%'
      AND co.order_id NOT LIKE 'FBA%'
      AND co.order_id NOT LIKE 'FK%'
),

daily_sales AS (
    SELECT
        sku_id,
        location_id,
        invoice_date,
        SUM(shipped_quantity) AS daily_shipped_qty
    FROM base_sales
    GROUP BY 1, 2, 3
)

SELECT * FROM daily_sales;
