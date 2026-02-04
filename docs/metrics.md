# Business Metrics Definitions

This document defines the core supply chain metrics used across analytics
models and AWS QuickSight dashboards. All metrics are defined centrally
in SQL to ensure consistency, reusability, and governance.

---

## 1. Days of Cover (DOC)

**Definition:**  
The number of days current available inventory can support demand based on
average daily sales velocity.

**Formula:**  
DOC = Available Quantity ÷ Average Daily Sales

**Grain:**  
SKU, Location

**Notes:**  
- Average Daily Sales is derived from Month-to-Date (MTD) sales
- Zero or null sales values are handled safely to avoid division errors
- DOC is used to identify stock-out risk and overstock situations

---

## 2. Required Inventory Quantity

**Definition:**  
The quantity of inventory required to meet demand for a target number of days.

**Formula:**  
Required Quantity = Average Daily Sales × Target DOC Days

**Default Target:**  
14 days

**Use Case:**  
Inventory planning, replenishment decisions, and procurement forecasting.

---

## 3. Average Daily Sales

**Definition:**  
The average number of units sold per active sales day in the current month.

**Formula:**  
Average Daily Sales = MTD Shipped Quantity ÷ Active Sales Days

**Grain:**  
SKU, Location

---

## 4. MTD Shipped Quantity

**Definition:**  
Total quantity shipped for a SKU at a location from the start of the current
month up to the current date.

---

## 5. Active Sales Days

**Definition:**  
Count of distinct days within the current month where at least one unit
was sold for a SKU at a location.

---

## Metric Governance Principles

- Metrics are defined once in analytics mart models
- Dashboards consume metrics without duplicating calculation logic
- Changes to metric definitions are version-controlled via SQL
- This approach ensures consistent reporting across teams and dashboards
