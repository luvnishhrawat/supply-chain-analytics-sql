-- Model: fact_inventory_metrics
-- Layer: mart
-- Description: Standardized inventory metrics including DOC and required quantity
-- Grain: sku_id, location_id
-- Downstream use: AWS QuickSight dashboards

WITH sales AS (
    SELECT
        sku_id,
        location_id,
        invoice_date,
        daily_shipped_qty
    FROM {{ ref('int_daily_sales') }}

),

mtd_sales AS (
    SELECT
        sku_id,
        location_id,
        SUM(daily_shipped_quantity) AS mtd_shipped_qty,
        COUNT(DISTINCT invoice_date) AS active_sales_days
    FROM sales
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
    FROM {{ref('int_inventory_snapshot') }}
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
