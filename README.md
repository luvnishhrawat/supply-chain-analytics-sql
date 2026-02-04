## Supply Chain Analytics – Core Metrics (SQL)

This project demonstrates how to model key
supply chain KPIs used by operations and
planning teams.

### Business questions answered
- Are we meeting demand? (Fill Rate)
- Where is inventory at risk?
- Which SKUs are slow-moving?
- How fast are products selling?

### Metrics covered
- Fill Rate
- Inventory availability
- Days of Cover (DOC)
- Sales velocity (7 / 14 / 30 days)

### Extended analytics scope
- DOC-based required quantity for inventory planning
- MTD vs MoM performance comparison
- WTD vs WoW performance comparison
- YTD vs YoY performance comparison
- Vendor open PO ageing & procurement risk
- Slow-moving and excess inventory identification

### Data assumptions
- SKU-level daily sales data
- Inventory snapshots by date
- Location / warehouse level granularity

## Analytics Architecture (Clean DAG)

This project follows a layered analytics engineering approach to ensure
metric consistency, reusability, and maintainability.

Each layer has a single responsibility:
- Intermediate models handle cleaning and reusable business logic
- Mart models define final, decision-ready business metrics

## BI Consumption (AWS QuickSight)

The analytics mart models are exposed to AWS QuickSight using custom SQL datasets.
This ensures that all dashboards consume standardized, governed metrics.

QuickSight usage pattern:
- One dataset per analytics mart
- Metrics are defined in SQL, not duplicated in visuals
- Filters and parameters control slicing, not metric logic

This approach enables:
- Consistent metrics across dashboards
- Self-serve exploration for business users
- Safe changes to logic without breaking reports
