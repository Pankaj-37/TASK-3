-- Drop database if it exists
DROP DATABASE IF EXISTS ecommerce_db;

-- Create new database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- ============================================
-- Table: Customers
-- ============================================
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    signup_date DATE
);

-- ============================================
-- Table: Products
-- ============================================
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(100),
    price DECIMAL(10,2)
);

-- ============================================
-- Table: Orders
-- ============================================
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- ============================================
-- Table: OrderItems
-- ============================================
CREATE TABLE OrderItems (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ============================================
-- Table: Payments
-- ============================================
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- ============================================
-- Sample Data
-- ============================================
-- Customers
INSERT INTO Customers (name, email, signup_date) VALUES 
('Alice', 'alice@example.com', '2023-05-15'),
('Bob', 'bob@example.com', '2023-08-01'),
('Charlie', 'charlie@example.com', '2023-03-22'),
('David', 'david@example.com', '2023-06-10'),
('Eve', 'eve@example.com', '2023-07-08');

-- Products
INSERT INTO Products (name, category, price) VALUES
('Laptop', 'Electronics', 999.99),
('Smartphone', 'Electronics', 699.99),
('Desk Chair', 'Furniture', 149.99),
('Book', 'Education', 19.99),
('Coffee Maker', 'Appliances', 89.99);

-- Orders
INSERT INTO Orders (customer_id, order_date, status) VALUES
(1, '2024-04-01', 'Completed'),
(2, '2024-04-02', 'Pending'),
(3, '2024-04-03', 'Completed'),
(4, '2024-04-04', 'Cancelled'),
(5, '2024-04-05', 'Completed');

-- OrderItems
INSERT INTO OrderItems (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 4, 2),
(2, 2, 1),
(3, 5, 1),
(4, 3, 1),
(5, 2, 2),
(5, 4, 1);

-- Payments
INSERT INTO Payments (order_id, payment_date, amount, payment_method) VALUES
(1, '2024-04-02', 1039.97, 'Credit Card'),
(3, '2024-04-04', 89.99, 'PayPal'),
(5, '2024-04-06', 1419.97, 'Debit Card');

-- 1. List all customers who signed up after July 1, 2023.
SELECT * FROM CUSTOMERS 
WHERE SIGNUP_DATE > '2023-07-01';
-- 2. Show all products in the "Electronics" category that cost more than ₹500.
SELECT NAME 
FROM PRODUCTS 
WHERE CATEGORY='ELECTRONICS' AND PRICE > 500;
-- 3. Find total number of orders placed by each customer.
SELECT DISTINCT CUSTOMER_ID , COUNT(ORDER_ID) AS TOTAL_ORDERS
FROM ORDERS 
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID
-- 4. Find the total quantity sold for each product.
SELECT P.NAME, SUM(O.QUANTITY) AS TOTAL_QUANTITY 
FROM PRODUCTS P INNER JOIN ORDERITEMS O USING(PRODUCT_ID)
GROUP BY P.NAME;
-- 5. Calculate total revenue generated from each product.
SELECT P.NAME AS PRODUCT_NAME,SUM(P.PRICE*O.QUANTITY) AS TOTAL_REVENUE
FROM PRODUCTS P JOIN ORDERITEMS O USING(PRODUCT_ID)
GROUP BY P.NAME
ORDER BY TOTAL_REVENUE DESC;
-- 6. List each order with customer name, order date, and total amount paid.
SELECT O.ORDER_ID ,C.name AS customer_name,O.ORDER_DATE,P.AMOUNT AS total_amount_paid
FROM ORDERS O 
JOIN PAYMENTS P 
USING (ORDER_ID)
JOIN CUSTOMERS C USING(CUSTOMER_ID);
-- 7. Find all orders along with their products and quantity.
SELECT O.ORDER_ID, P.NAME AS PRODUCT_NAME , O.QUANTITY 
FROM ORDERITEMS O
INNER JOIN  PRODUCTS P
USING (PRODUCT_id);
-- 8. Find customers who placed orders worth more than ₹1000 in total.
SELECT C.CUSTOMER_ID, C.name AS CUSTOMER_NAME ,SUM(P.AMOUNT) AS AMOUNT_SPEND 
FROM CUSTOMERS C
INNER JOIN ORDERS  O 
USING (CUSTOMER_ID)
INNER JOIN PAYMENTS P USING (ORDER_ID)
GROUP BY C.CUSTOMER_ID, C.name 
HAVING AMOUNT_SPEND >1000;

-- 9. List products that were never ordered.
SELECT * FROM Products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM OrderItems
);
-- 10. Show customers who placed more than 1 order.
SELECT customer_id, COUNT(*) AS total_orders
FROM Orders
GROUP BY customer_id
HAVING total_orders > 1;
-- 11. Create a view named `high_spenders` that shows customers who spent more than ₹1000.
CREATE VIEW high_spenders AS
SELECT c.customer_id, c.name, SUM(p.amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.name
HAVING total_spent > 1000;

-- 12. Create indexes to optimize query performance.
CREATE INDEX idx_customer_id ON Orders(customer_id);
CREATE INDEX idx_product_id ON OrderItems(product_id);

-- 13. Find the most popular payment method.
SELECT payment_method, COUNT(*) AS total
FROM Payments
GROUP BY payment_method
ORDER BY total DESC
LIMIT 1;

-- 14. Calculate average revenue per customer.
SELECT AVG(total_spent) AS avg_revenue_per_customer
FROM (
    SELECT c.customer_id, SUM(p.amount) AS total_spent
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN Payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id
) AS revenue;

-- 15. List orders with multiple items.
SELECT order_id, COUNT(*) AS item_count
FROM OrderItems
GROUP BY order_id
HAVING item_count > 1;

