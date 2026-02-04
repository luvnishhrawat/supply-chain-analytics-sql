-- Model: fact_inventory_metrics
-- Layer: mart
-- Description: Standardized inventory metrics including DOC and required quantity
-- Grain: date, sku_id, location_id
-- Downstream use: AWS QuickSight dashboards

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

mtd_sales AS (
    SELECT
        sku_id,
        location_id,
        SUM(shipped_quantity) AS mtd_shipped_qty,
        COUNT(DISTINCT invoice_date) AS active_sales_days
    FROM base_sales
    WHERE invoice_date >= DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY 1,2
),

sales_velocity AS (
    SELECT
        sku_id,
        location_id,
        mtd_shipped_qty / NULLIF(active_sales_days,0) AS avg_daily_sales
    FROM mtd_sales
),

current_inventory AS (
    SELECT
        sku_id,
        location_id,
        available_qty
    FROM inventory_snapshot
    WHERE snapshot_date = CURRENT_DATE
)

SELECT
    v.sku_id,
    v.location_id,
    v.avg_daily_sales,
    14 AS target_doc_days,
    ROUND(v.avg_daily_sales * 14, 2) AS required_qty,
    i.available_qty,
    ROUND((v.avg_daily_sales * 14) - i.available_qty, 2)
        AS shortage_or_excess_qty
FROM sales_velocity v
LEFT JOIN current_inventory i
    ON v.sku_id = i.sku_id
   AND v.location_id = i.location_id;
