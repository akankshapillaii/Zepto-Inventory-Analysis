Drop table if exists Zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY, 
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuanitity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGrams INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);

--data exploration

-- count of rows
SELECT COUNT(*) FROM zepto;

--sample data
SELECT * FROM zepto
LIMIT 10;

--Renaming the column due to error
ALTER TABLE zepto
RENAME COLUMN availableQuanitity TO availableQuantity;

--null values
SELECT * FROM zepto
WHERE name IS NULL
OR 	
category IS NULL
OR 
mrp IS NULL
OR 
discountpercent IS NULL
OR  
availablequantity IS NULL
OR 
discountedsellingprice IS NULL
OR 
weightingrams IS NULL
OR 
outofstock IS NULL
OR 
quantity IS NULL;

--different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stock vs out of stock
SELECT outofstock, COUNT (sku_id)
FROM zepto
GROUP BY outofstock;

--repetative product names
SELECT name, Count(sku_id) as "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

--data cleaning

--products with price = 0
SELECT * FROM zepto 
WHERE mrp = 0 OR discountedsellingprice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--convert paise to rupees
UPDATE zepto
SET mrp = mrp/100.0,
discountedsellingprice = discountedsellingprice/100.0;

SELECT mrp, discountedsellingprice FROM zepto;

--1. Top 10 best value products based on discount percentage.
SELECT DISTINCT name, mrp, discountpercent
FROM zepto 
ORDER BY discountpercent DESC
LIMIT 10;

--2.Products with high mrp but out of stock.
SELECT DISTINCT name, mrp, outofstock
FROM zepto
WHERE outofstock = TRUE and mrp > 300
ORDER BY mrp DESC;

--3. Calculating estimated revenue for each category.
SELECT category,
SUM(discountedSellingPrice * availablequantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

--4. All products where mrp is greater than 500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountpercent
FROM zepto
WHERE mrp > 500 AND discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC; 

--5. Top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountpercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC 
LIMIT 5;

--6.Price per gram for products above 100g and sort by best value.
SELECT distinct name, weightingrams, discountedsellingprice,
ROUND(discountedsellingprice/weightingrams,2) AS price_per_gram
FROM zepto
WHERE weightingrams >= 100
ORDER BY price_per_gram;

--7.Grouping products into categories like low, medium, bulk.
SELECT DISTINCT name, weightingrams, 
CASE WHEN weightingrams <1000 THEN 'Low'
	WHEN weightingrams <5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--8.Total inventory weight per category.
SELECT category, 
SUM (weightingrams * availablequantity) AS total_weight
FROM zepto 
GROUP BY category
ORDER BY total_weight;