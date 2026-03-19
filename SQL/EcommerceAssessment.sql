CREATE DATABASE EcommerceDB;
GO

-- Use the new database
USE EcommerceDB;
GO

-- 4 tables creation
-- ----------------- CUSTOMERS -----------------
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(25),
    signup_date DATE
);
GO

-- ----------------- PRODUCTS -----------------
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(25) ,
    product_price DECIMAL (10,2)
);
GO

-- ----------------- ORDERS -----------------
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_value DECIMAL(10,2),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
GO

-- ----------------- ORDER ITEMS -----------------
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_orderitems_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);
GO

--inserting the tables the csv files i created using python 
BULK INSERT customers
FROM 'C:\temp\customers (1).csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

BULK INSERT order_items
FROM 'C:\temp\order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);


BULK INSERT orders
FROM 'C:\temp\orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

BULK INSERT products
FROM 'C:\temp\products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);


--5 business questions 

-- MONTHLY SALES AND MOM%

WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(order_value) AS total_sales
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
),
final AS (
    SELECT *,
        LAG(total_sales) OVER (
            ORDER BY year, month
        ) AS prev_month_sales
    FROM monthly_sales
)

SELECT 
    year,
    month,
    total_sales,
    prev_month_sales,
    CONCAT(
        ROUND(
            (total_sales - prev_month_sales) * 100.0 
            / NULLIF(prev_month_sales, 0), 
        2),
        '%'
    ) AS mom_growth_pct
FROM final
ORDER BY year, month;


-- TOP 5 CUSTOMERS BY TOTAL PURCHASE 
SELECT TOP 5
    c.customer_id,
    c.customer_name,
    SUM(o.order_value) AS total_spent
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

--products never ordered
SELECT 
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;



--average order value and rank cities by performance

WITH city_avg AS (
    SELECT 
        c.city,
        AVG(o.order_value) AS avg_order_value
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.city
)

SELECT *,
    RANK() OVER (ORDER BY avg_order_value DESC) AS city_rank
FROM city_avg;


--customers who placed more than 3 orders in the last 6 months
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_date >= DATEADD(MONTH, -6, GETDATE())
GROUP BY c.customer_id, c.customer_name 
HAVING COUNT(o.order_id) > 3;

