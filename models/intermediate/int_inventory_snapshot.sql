-- Model: int_inventory_snapshot
-- Layer: intermediate
-- Description: Latest available inventory snapshot at sku-location grain
-- Grain: sku_id, location_id

SELECT
    sku_id,
    location_id,
    available_qty
FROM inventory_snapshot
WHERE snapshot_date = CURRENT_DATE
