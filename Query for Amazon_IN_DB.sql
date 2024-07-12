-- Amazon_IN_DB

-- creating customers table
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
                            customer_id VARCHAR(25) PRIMARY KEY,
                            customer_name VARCHAR(25),
                            state VARCHAR(25)
);

-- creating sellers table
DROP TABLE IF EXISTS sellers;
CREATE TABLE sellers (
                        seller_id VARCHAR(25) PRIMARY KEY,
                        seller_name VARCHAR(25)
);

-- creating products table
DROP TABLE IF EXISTS products;
CREATE TABLE products (
                        product_id VARCHAR(25) PRIMARY KEY,
                        product_name VARCHAR(255),
                        Price FLOAT,
                        cogs FLOAT
);

-- creating orders table
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
                        order_id VARCHAR(25) PRIMARY KEY,
                        order_date DATE,
                        customer_id VARCHAR(25),  -- this is a foreign key from customers(customer_id)
                        state VARCHAR(25),
                        category VARCHAR(25),
                        sub_category VARCHAR(25),
                        product_id VARCHAR(25),   -- this is a foreign key from products(product_id)
                        price_per_unit FLOAT,
                        quantity INT,
                        sale FLOAT,
                        seller_id VARCHAR(25),    -- this is a foreign key from sellers(seller_id)
    
                        CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
                        CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),    
                        CONSTRAINT fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- creating returns table
DROP TABLE IF EXISTS returns;
CREATE TABLE returns (
                        order_id VARCHAR(25),
                        return_id VARCHAR(25),
                        CONSTRAINT pk_returns PRIMARY KEY (order_id), -- Primary key constraint
                        CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- CLASS EXERCISE BEGINS

DROP TABLE IF EXISTS shippings;

CREATE TABLE shippings (
							id INT PRIMARY KEY,
							provider_name VARCHAR(25),
							email_id VARCHAR(25)
);

INSERT INTO shippings
VALUES
(101, 'dhl');

SELECT * FROM shippings;

INSERT INTO shippings (id)
VALUES
(102),
(103);

UPDATE shippings
SET provider_name = 'Bluedart', email_id = '123@gmail.com'
WHERE id = 102;

UPDATE shippings
SET provider_name = 'Dhl'
WHERE id = 101;

DELETE FROM shippings
WHERE id = 103;

-- Delete a column
ALTER TABLE shippings
DROP COLUMN email_id;

-- Add a column
ALTER TABLE shippings
ADD COLUMN email_id VARCHAR(25);

-- Rename table name
ALTER TABLE shippings
RENAME to shipping;

SELECT * FROM shipping;

-- Rename table column name
ALTER TABLE shipping
RENAME COLUMN email_id to email;

-- Update datatypes of an existing column
ALTER TABLE shipping
ALTER COLUMN email TYPE VARCHAR(15);

-- CLASS EXERCISE ENDS

-- Business Problems 5

-- Q19. Find Top 5 states by total orders where each state sale is greater than average orders accross orders.
-- state, 

SELECT * FROM orders;

SELECT 
		state,
		COUNT(*) as Total_orders,
		SUM(sale) as State_sale
FROM orders
GROUP BY state
HAVING SUM(sale) > (SELECT AVG(sale) as Average_orders FROM orders)
ORDER BY Total_orders DESC
LIMIT 5;


-- Q20. Find the details of the top 5 products with the highest total sales, where the total sale for each product is greater than the average sale across all products.
-- Product_id, SUM(Sales) Group By Product_id
-- Order By Sum(sales) and limit 5
-- Each product sale -- Product_id, SUM(Sales) Group By Product_id
-- Sum(sale) / Count(product_id)

SELECT * FROM products;
SELECT * FROM orders;

WITH CTE1
AS
(
SELECT
		product_id,
		SUM(sale) as Total_sale_by_productid
FROM orders
GROUP BY product_id
ORDER BY SUM(sale) DESC
LIMIT 5
)

SELECT AVG(total_sale_by_productid) as Avg_Sale FROM CTE1;

-- We can also do Subquery as below instead of CTE
SELECT
		product_id,
		SUM(sale) as total_sale_by_productid
FROM orders
GROUP BY product_id
HAVING SUM(sale) > (SELECT
					AVG(total_sale_by_productid) as Avg_Sale
					FROM
						(
						SELECT
							product_id,
							SUM(sale) as Total_sale_by_productid
							FROM orders
							GROUP BY product_id
							ORDER BY SUM(sale) DESC
						) as avg_sale_table)
ORDER BY SUM(sale)
LIMIT 5;

-- Business Problems 7

-- Q21. List all orders along with the product details (product name, price) and seller details (seller name) for each order.

SELECT * FROM products;

SELECT 
		o.order_id,
		p.product_name,
		p.price,
		s.seller_id,
		s.seller_name
FROM orders as o
JOIN products as p
ON o.product_id = p.product_id
JOIN sellers as s
ON o.seller_id = s.seller_id;

-- Q22. Find the total sales amount for each category.

SELECT 
		category,
		SUM(sale) as Total_sales
FROM orders
WHERE category IS NOT NULL
GROUP BY category;

-- Q23. List all customers who have made returns along with the number of returns made by each customer.

SELECT * FROM orders;

SELECT
	c.customer_id,
	c.customer_name,
	COUNT(r.return_id) as Total_returns
FROM customers as c
JOIN orders as o
ON c.customer_id = o.customer_id
JOIN returns as r
ON o.order_id = r.order_id
GROUP BY c.customer_id
ORDER BY Total_returns DESC;

-- Q24. Find the average price of products sold by each seller.

SELECT 
	s.seller_id,
	AVG(price) as Average_price
FROM products as p
JOIN orders as o
ON p.product_id = o.product_id
JOIN sellers as s
ON s.seller_id = o.seller_id
GROUP BY p.product_id, s.seller_id;

-- Q25. Identify the top 3 sellers based on the total sales amount.

SELECT 
	o.seller_id,
	s.seller_name,
	SUM(sale) as Total_sales
FROM orders as o
JOIN sellers as s
ON o.seller_id = s.seller_id
GROUP BY 1, 2
ORDER BY Total_sales DESC
LIMIT 3;

-- Q26. List all orders where the quantity sold is greater than the average quantity sold across all orders.

SELECT 
	order_id,
	SUM(quantity) as Quantity_sold
FROM orders
GROUP BY order_id
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM orders)
ORDER BY Quantity_sold DESC;

-- Q27. Find the total sales amount for each category in each state.
-- SUM(sale), category, state

SELECT 
	state,
	category,
	SUM(sale) as Total_sales
FROM orders
GROUP BY state, category;

-- Q28. List the products that have not been sold yet.

SELECT * FROM orders;

SELECT 
	p.product_id,
	p.product_name
FROM products as p
LEFT JOIN
orders as o
ON o.product_id = p.product_id
WHERE o.product_id IS NULL;

-- Q29. Find the total sales amount for each seller, excluding the sales amount for orders with returns.
-- Sum(sale), Group by seller_id,

SELECT * FROM returns;

SELECT
	o.seller_id,
	SUM(o.sale) as Total_sales
FROM orders as o
LEFT JOIN
returns as r
ON o.order_id = r.return_id
WHERE r.order_id IS NULL
GROUP BY o.seller_id;

-- Q30. Identify the customers who have made orders in more than one state.

SELECT
	o.customer_id,
	c.customer_name
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.state) > 1;

-- STRING FUNCTIONS begins

-- CONCAT Function

SELECT CONCAT ('Sha', 'Mili');

SELECT * FROM customers;

ALTER TABLE customers
ADD COLUMN last_name VARCHAR(25);

INSERT INTO customers(customer_id, customer_name, last_name)
VALUES
('CS10001', 'Mili', 'Shamili');

SELECT * FROM customers
WHERE customer_id = 'CS10001';

SELECT CONCAT(customer_name, ' ', last_name)
FROM customers
WHERE customer_id = 'CS10001';

DELETE FROM customers
WHERE customer_id = 'CS10001';

ALTER TABLE customers
DROP COLUMN last_name;

SELECT * FROM customers;

-- LEFT/RIGHT Function

SELECT LEFT('Hello World', 5); -- Output is Hello
SELECT RIGHT('Hello World', 5); -- Output is World

-- TRIM Function (Deletes space from starting and ending words)

SELECT TRIM(' 	Hi I am Mili	  ');

-- REPLACE Function

SELECT REPLACE('Hello World', 'World', 'Universe'); -- Outpu: 'Hello Universe'

-- STRING FUNCTION Ends

-- NUMBER FUNCTIONS
-- ROUND Function

SELECT ROUND(1298.849587083,2) as Total_sale;

-- ABS Function (Gives positive values)

SELECT ABS(-250) AS loss;

-- RANDOM Function (Gives a random number from 0 to 1)

SELECT RANDOM();

-- Handlind Null values

SELECT * FROM shippings
WHERE provider_name IS NULL;

SELECT * FROM shippings
WHERE provider_name IS NULL OR email_id IS NULL;

SELECT COUNT(*) FROM orders
WHERE order_id IS NULL OR product_id IS NULL;

-- CASE STATEMENT

-- Q31. Classify orders by quantity: 
-- Categorize orders as "Low," "Medium," or "High" based on the quantity ordered.

-- Avg 3.7
-- Min 1
-- Max 14

SELECT * FROM orders;

SELECT MAX(quantity) FROM orders;

SELECT
	order_id,
	quantity,
	CASE
		WHEN quantity < 3 THEN 'Low Quantity'
		WHEN quantity BETWEEN 3 AND 10 THEN 'Medium Quantity'
		ELSE 'High Quantity'
	END AS Quantity_Category
FROM orders;

-- Q32. Categorize products by price range:
-- Classify products as "Low," "Medium," or "High" based on their price.

-- classification

-- price > 1000 'High Price'
-- price between 68 and 1000 'Medium Price'
-- Price < 68 'Low Price'

SELECT * FROM products;

-- avg 68
-- max 3700
-- min 0.36

SELECT *,
	CASE
		WHEN price > 1000 THEN 'High Price Product'
		WHEN price BETWEEN 68 AND 1000 THEN 'Medium Price Product'
		ELSE 'Low Price Product'
	END as product_category
FROM products;

-- Q33. Identify returning customers: 
-- Label customers as "Returning" if they have placed more than one returns; otherwise, mark them as "New."
-- If return > 1 then 'returning' else new_cs
-- How many orders cx has placed
-- How many orders cx has returned - join return table
-- cx join with cx table

SELECT * FROM orders;

SELECT * FROM returns;

SELECT * FROM customers;

SELECT
	o.customer_id,
	c.customer_name,
	COUNT(o.order_id) as total_orders,
	COUNT(r.return_id) as total_return,
	CASE
		WHEN COUNT(r.return_id) > 1 THEN 'returning_cs'
		ELSE 'new_cs'
	END
FROM orders as o
LEFT JOIN
returns as r
ON o.order_id = r.order_id
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name;

-- Q34. Determine seller performance: 
-- Evaluate sellers as "Top Performer" if their total sales amount exceeds the average sales amount; 
-- otherwise, classify them as "Average Performer."

SELECT AVG(sale) from orders;

SELECT 
	s.seller_name,
	SUM(sale) as Total_sales,
	CASE
		WHEN SUM(sale) > (AVG(sale)) THEN 'Top Performer'
		ELSE 'Average Performer'
	END AS Seller_Performance
FROM orders as o
JOIN sellers as s
ON o.seller_id = s.seller_id
GROUP BY s.seller_name;

-- Window Function

-- Business Problems 7

-- Q1. Ranking Top 5 Products by Sales: 

SELECT *
FROM
(
SELECT
	product_id,
	SUM(sale) as Total_sale,
	RANK() OVER(ORDER BY SUM(sale) DESC) AS rank
FROM orders
GROUP BY product_id
)
WHERE rank <= 5;

-- Q2. Find the top 3 products based on total sales,
-- along with their sales figures.

SELECT
	o.product_id,
	p.product_name,
	SUM(sale) as Total_sales
FROM orders as o
LEFT JOIN products as p
ON o.product_id = p.product_id
GROUP BY o.product_id, p.product_name
ORDER BY 3 DESC
LIMIT 3;

-- Q35. Identifying Customer Loyalty: 
-- Rank customers based on the total number of orders placed, 
-- showing their rank and the corresponding customer ID and customer full name.

SELECT 
	o.customer_id,
	c.customer_name,
	COUNT(1) as Total_orders,
	RANK() OVER(ORDER BY COUNT(1) DESC) AS rank
FROM orders as o
JOIN customers as c
ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name;

