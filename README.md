# Zepto-Inventory-Analysis

SQL | PostgreSQL | Data Cleaning | Exploratory Data Analysis | Inventory Analytics

An SQL-based analysis of Zepto product inventory data to uncover insights across pricing, discounts, stock availability, inventory value, and product assortment.

This analysis demonstrates how raw product data can be cleaned, transformed, and analyzed to answer practical inventory and pricing business questions.

-----

## Executive Summary

This project uses **SQL to explore, clean, and analyze Zepto product inventory data**.

The analysis begins with data-quality checks to understand the structure of the dataset, identify missing values, detect duplicate product names, and examine stock availability across categories.

After cleaning the data, the analysis focuses on several business questions:

* Which products offer the highest discounts?
* Which high-value products are currently out of stock?
* Which categories represent the highest estimated inventory revenue?
* Which expensive products have relatively low discounts?
* Which categories offer the highest average discounts?
* Which products provide better price-to-weight value?
* How can products be grouped based on their inventory weight?
* Which categories carry the highest total inventory weight?

The project demonstrates how **SQL can move from raw inventory data to business-focused analysis** through data exploration, cleaning, aggregation, filtering, and derived metrics.

----------

## Table of Contents

* [Business Problem](#-business-problem)
* [Project Objective](#-project-objective)
* [Key Stakeholders](#-key-stakeholders)
* [Project Workflow](#-project-workflow)
* [Dataset Structure](#-dataset-structure)
* [Data Exploration & Quality Checks](#-data-exploration--quality-checks)
* [Data Cleaning](#-data-cleaning)
* [Analysis & Business Questions](#-analysis--business-questions)
* [Business Recommendations](#-business-recommendations)
* [Conclusion](#-conclusion)

-----------

## Business Problem

A large product catalog requires continuous monitoring of **pricing, discounts, availability, and inventory levels**.

Without structured analysis, it can be difficult to identify:

* Products with unusually high or low discounts
* High-priced products that are unavailable
* Categories carrying significant inventory
* Products offering better value based on price and weight
* Categories with stronger discount strategies
* Potential inventory concentration across product categories

The objective of this project is to use SQL to convert product-level inventory data into **actionable information for pricing, inventory, and assortment decisions**.

---

## Project Objective

The analysis was designed to answer the following business questions:

1. Which are the **top 10 products based on discount percentage**?
2. Which **high-MRP products are currently out of stock**?
3. What is the **estimated inventory revenue by category**?
4. Which products have an **MRP above ₹500 but a discount below 10%**?
5. Which categories have the **highest average discount percentage**?
6. Which products provide the **lowest price per gram**?
7. How can products be classified into **Low, Medium, and Bulk** weight categories?
8. Which categories contain the **highest total inventory weight**?

---

## Key Stakeholders

- **Inventory & Operations Teams:**
Monitor stock availability, inventory levels, and category-level inventory concentration.

- **Pricing Teams:**
Evaluate MRP, selling price, discount percentages, and price-to-weight value.

- **Category Managers:**
Understand category-level revenue potential, discount patterns, and inventory distribution.

- **Business Management:**
Use consolidated inventory and product insights to support assortment and commercial decisions.

- **Data / BI Teams:**
Maintain data quality, SQL analysis, reporting logic, and analytical workflows

---

## Project Workflow

```text
Raw Product Data
        ↓
Data Exploration
        ↓
Data Quality Checks
        ↓
Data Cleaning
        ↓
Data Transformation
        ↓
Business Analysis
        ↓
Category & Product Insights
        ↓
Business Recommendations
```
---

## Dataset Structure

The `zepto` table contains product-level information across pricing, inventory, availability, and product characteristics.

| Column                   | Description                                   |
| ------------------------ | --------------------------------------------- |
| `sku_id`                 | Unique SKU identifier                         |
| `category`               | Product category                              |
| `name`                   | Product name                                  |
| `mrp`                    | Maximum Retail Price                          |
| `discountPercent`        | Product discount percentage                   |
| `availableQuantity`      | Available inventory quantity                  |
| `discountedSellingPrice` | Selling price after discount                  |
| `weightInGrams`          | Product weight in grams                       |
| `outOfStock`             | Indicates whether the product is out of stock |
| `quantity`               | Product quantity field                        |

The original table definition and field structure are included directly in the SQL source.

---

# Data Exploration & Quality Checks

Before performing business analysis, the dataset was examined to understand its structure and identify potential data-quality issues.

### 1. Row Count

The analysis begins by checking the total number of records in the `zepto` table.

```sql
SELECT COUNT(*) FROM zepto;
```

### 2. Sample Data

A sample of records was reviewed to understand the available product information.

```sql
SELECT * FROM zepto
LIMIT 10;
```

### 3. Column Consistency

A column-name issue was identified and corrected:

```sql
ALTER TABLE zepto
RENAME COLUMN availableQuanitity TO availableQuantity;
```

### 4. Missing Values

The analysis checks for NULL values across important product, pricing, inventory, and weight fields.

This helps ensure that subsequent calculations are based on sufficiently complete records.

### 5. Product Categories

Distinct product categories were reviewed to understand the breadth of the catalog.

```sql
SELECT DISTINCT category
FROM zepto
ORDER BY category;
```

### 6. Stock Availability

Products were grouped by their `outOfStock` status to compare available and unavailable inventory.

```sql
SELECT outofstock, COUNT(sku_id)
FROM zepto
GROUP BY outofstock;
```

### 7. Repetitive Product Names

Repeated product names were identified to understand whether multiple SKUs exist for the same product.

```sql
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;
```

---

# Data Cleaning

Data preparation was performed before the business analysis.

### Removing Invalid Price Records

Products with an MRP of zero were identified and removed:

```sql
DELETE FROM zepto
WHERE mrp = 0;
```

This prevents zero-priced records from distorting pricing-related analysis.

### Converting Paise to Rupees

The pricing fields were converted into rupees:

```sql
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;
```

This ensures that subsequent price analysis is interpreted in the correct monetary unit.

---

# Analysis & Business Questions

## 1. Top 10 Best-Value Products by Discount

The first analysis identifies products offering the highest discount percentages.

```sql
SELECT DISTINCT name, mrp, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;
```

### Business Question

> Which products currently offer the strongest discounts to customers?

### Business Use

This can help pricing and category teams identify heavily discounted products and evaluate promotional strategies.

---

## 2. High-MRP Products That Are Out of Stock

Products with an MRP above ₹300 and an out-of-stock status are identified.

```sql
SELECT DISTINCT name, mrp, outofstock
FROM zepto
WHERE outofstock = TRUE
AND mrp > 300
ORDER BY mrp DESC;
```

### Business Question

> Which relatively high-value products are unavailable?

### Business Use

These products may represent potential lost sales opportunities and can be prioritized for inventory review.

---

## 3. Estimated Revenue by Category

Estimated inventory revenue is calculated using:

**Discounted Selling Price × Available Quantity**

```sql
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;
```

### Business Question

> Which categories hold the greatest estimated revenue potential based on their available inventory?

### Business Use

This provides a category-level view of the monetary value represented by currently available inventory.

---

## 4. High-MRP Products With Low Discounts

Products priced above ₹500 with discounts below 10% are identified.

```sql
SELECT DISTINCT name, mrp, discountpercent
FROM zepto
WHERE mrp > 500
AND discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC;
```

### Business Question

> Which expensive products currently have relatively limited discounts?

### Business Use

These products can be reviewed to understand whether their pricing and promotional positioning align with category strategy.

---

## 5. Categories With the Highest Average Discount

The average discount percentage is calculated for every category.

```sql
SELECT category,
       ROUND(AVG(discountpercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
```

### Business Question

> Which categories rely most heavily on discounting?

### Business Use

Category-level discount patterns can help evaluate promotional intensity and pricing strategy.

---

## 6. Price Per Gram Analysis

For products weighing at least 100 grams, price per gram is calculated.

```sql
SELECT DISTINCT
       name,
       weightInGrams,
       discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGrams, 2) AS price_per_gram
FROM zepto
WHERE weightInGrams >= 100
ORDER BY price_per_gram;
```

### Business Question

> Which products offer the lowest price relative to their weight?

### Business Use

Price-per-gram analysis provides a standardized way to compare products with different package sizes.

---

## 7. Product Weight Classification

Products are segmented into three weight groups:

| Weight              | Classification |
| ------------------- | -------------- |
| `< 1,000g`          | Low            |
| `1,000g – < 5,000g` | Medium         |
| `≥ 5,000g`          | Bulk           |

```sql
SELECT DISTINCT
       name,
       weightInGrams,
       CASE
           WHEN weightInGrams < 1000 THEN 'Low'
           WHEN weightInGrams < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS weight_category
FROM zepto;
```

### Business Question

> How is the product catalog distributed by product size?

### Business Use

Weight segmentation can support inventory planning, assortment analysis, and logistics-related decisions.

---

## 8. Total Inventory Weight by Category

The total inventory weight is calculated using:

**Product Weight × Available Quantity**

```sql
SELECT category,
       SUM(weightInGrams * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;
```

### Business Question

> Which categories represent the greatest physical inventory volume?

### Business Use

This can help operations teams understand inventory concentration and potential storage or handling requirements.

---

# Business Recommendations

### 1. Prioritize High-Value Out-of-Stock Products

Review high-MRP products that are currently unavailable and prioritize replenishment based on demand, historical sales, and inventory turnover.

**Goal:** Reduce potential lost sales from valuable products being unavailable.

---

### 2. Review Categories With High Discount Intensity

Categories with unusually high average discounts should be monitored to understand whether discounting is driving demand or reducing potential margins.

**Goal:** Balance customer attractiveness with sustainable pricing.

---

### 3. Use Inventory Revenue Potential for Category Planning

The estimated revenue calculation can be used as an initial indicator of where significant monetary inventory is concentrated.

**Goal:** Focus inventory planning and monitoring on categories with higher financial exposure.

---

### 4. Use Price-per-Gram for Better Product Comparisons

Price-per-gram analysis can help identify products that provide stronger value relative to their package size.

**Goal:** Improve product comparisons and support more informed pricing and assortment decisions.

---

### 5. Monitor High-MRP, Low-Discount Products

Products above ₹500 with discounts below 10% should be reviewed alongside their category, demand, and competitive pricing.

**Goal:** Identify products where pricing adjustments or targeted promotions may be worth evaluating.

---

### 6. Combine Monetary and Physical Inventory Analysis

Category-level estimated revenue should be reviewed together with total inventory weight.

**Goal:** Understand not only where financial inventory is concentrated, but also where physical inventory requirements may be highest.

---

# Conclusion

The Zepto Inventory Analysis demonstrates how SQL can be used to move from **raw product-level data to structured business analysis**.

Rather than focusing only on individual products, the project connects multiple dimensions of the catalog—including **pricing, discounts, availability, quantity, weight, and category**—to answer practical inventory and commercial questions.

The analysis establishes a foundation for deeper analytics such as **inventory turnover, margin analysis, demand forecasting, stock-out impact, discount effectiveness, and category profitability** when additional sales and operational data become available.
