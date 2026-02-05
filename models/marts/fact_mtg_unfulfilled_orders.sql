-- Model: fact_mtg_unfulfilled_orders
-- Layer: mart
-- Description: Unfulfilled B2B order lines enriched with vendor open PO quantity and latest inbound date (MTG view) and Appointment Date
-- Grain: order_id, sku_id, location_id
-- Downstream use: AWS QuickSight MTG dashboards

WITH vendor_po AS (
    SELECT *
    FROM {{ ref('int_vendor_open_po') }}
),

latest_appointment AS (
    SELECT
        channel_order_id,
        appointment_status,
        appointment_confirmed_date
    FROM (
        SELECT
            channel_order_id,
            appointment_status,
            appointment_confirmed_date,
            ROW_NUMBER() OVER (
                PARTITION BY channel_order_id
                ORDER BY appointment_confirmed_date DESC
            ) AS rn
        FROM channel_order_appointments
    ) t
    WHERE rn = 1
)

SELECT
    brg.name AS brand_group,
    sc.description AS product_name,
    li.status,
    l.city AS location,
    sc.bar_code,
    s.code AS sku_code,
    co.order_id,
    co.erp_order_id,
    co.order_type,
    br.name AS brand_name,
    sc.mrp,

    li.quantity,
    li.committed_quantity,
    li.picked_quantity,
    li.open_quantity AS unfulfillable_units,

    li.quantity * li.unit_price AS po_value,
    li.unit_price,
    li.unit_price_without_tax,
    li.line_number,

    csm.channel_product_id,

    li.committed_quantity * li.unit_price AS committed_value,
    li.picked_quantity * li.unit_price AS picked_value,

    li.closed_quantity,
    li.open_quantity * li.unit_price AS unfulfillable_value,

    vp.vendor_open_qty,
    DATE(vp.latest_inbound_date) AS latest_inbound_date,

    CASE 
        WHEN vp.latest_inbound_date IS NULL THEN NULL
        ELSE DATEDIFF(vp.latest_inbound_date, co.order_date)
    END AS po_ageing_days,

    co.order_date,
    la.appointment_confirmed_date AS appointment_date,

    CASE 
        WHEN c.name IS NULL THEN 'Others'
        ELSE c.name
    END AS channel_name,

    MONTHNAME(co.order_date) AS month,
    YEAR(co.order_date) AS year

FROM channel_orders co
JOIN channel_order_line_items li
    ON li.channel_order_id = co.id

LEFT JOIN channels c
    ON co.channel_id = c.id

LEFT JOIN skus s
    ON s.id = li.sku_id

LEFT JOIN sku_contents sc
    ON s.id = sc.sku_id

LEFT JOIN brands br
    ON s.brand_id = br.id

LEFT JOIN brand_groups brg
    ON br.brand_group_id = brg.id

INNER JOIN locations l
    ON co.location_id = l.id

LEFT JOIN channel_sku_mappings csm
    ON s.id = csm.sku_id
   AND csm.channel_id = c.id
   AND sc.mrp = csm.mrp

LEFT JOIN vendor_po vp
    ON vp.sku_code = s.code
   AND vp.city = l.city

LEFT JOIN latest_appointment la
    ON la.channel_order_id = co.id

WHERE co.order_type = 'B2B'
  AND li.status IN (
      'Allocated', 'Packed', 'Part Allocated',
      'Part Picked', 'Pick Complete', 'confirmed'
  )
  AND li.api_synced = 1
  AND li.shipped_quantity = 0;
