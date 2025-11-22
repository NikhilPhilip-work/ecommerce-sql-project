-- 1.TOTAL NO. OF USERS
SELECT COUNT(*) AS total_users
FROM users;

-- 2.REVENUE TILL NOW
SELECT 
    SUM(order_items.item_total) AS total_revenue
FROM order_items;

-- 3.TOTAL ORDERS
SELECT COUNT(*) AS total_orders
FROM orders;

-- 4.PRODUCTS SOLD TILL NOW 
    SELECT 
    SUM(order_items.quantity) AS total_products_sold
FROM order_items ;

-- 5. ACTIVE USERS
SELECT 
    COUNT(DISTINCT orders.user_id) AS active_users
FROM orders;

-- 6. Top Countries with Most Users
SELECT 
    users.country,
    COUNT(*) AS user_count,
    (COUNT(*) * 100.0 / 500) AS percentage
FROM users
GROUP BY users.country
ORDER BY user_count DESC;

-- 7. USERS BY GENDER
SELECT 
    users.gender,
    COUNT(*) AS user_count,
    (COUNT(*) * 100.0 / 500) AS percentage
FROM users
GROUP BY users.gender
ORDER BY user_count DESC;

-- 8. REVENUE BY GENDER
SELECT 
    users.gender,
    SUM(order_items.item_total) AS revenue
FROM orders
JOIN users 
    ON orders.user_id = users.user_id
JOIN order_items
    ON orders.order_id = order_items.order_id
GROUP BY users.gender
ORDER BY revenue DESC;


-- 9. NEW USERS PER MONTH
SELECT 
    DATE_FORMAT(users.signup_date, '%Y-%m') AS signup_month,
    COUNT(*) AS new_customers
FROM users
GROUP BY signup_month
ORDER BY signup_month;

-- 10. Highest Revenue Age Groups
SELECT 
    grouped_users.age_group,
    SUM(order_items.item_total) AS revenue,
    COUNT(DISTINCT grouped_users.user_id) AS user_count
FROM (
    SELECT 
        users.user_id,
        CASE
            WHEN users.age BETWEEN 18 AND 24 THEN '18-24'
            WHEN users.age BETWEEN 25 AND 34 THEN '25-34'
            WHEN users.age BETWEEN 35 AND 44 THEN '35-44'
            WHEN users.age BETWEEN 45 AND 54 THEN '45-54'
            WHEN users.age BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65+'
        END AS age_group
    FROM users
) AS grouped_users
JOIN orders 
    ON grouped_users.user_id = orders.user_id
JOIN order_items 
    ON orders.order_id = order_items.order_id
GROUP BY grouped_users.age_group
ORDER BY revenue DESC;

-- 11. TOP 10 HIGH VALUE CUSTOMERS
SELECT 
    orders.user_id,
    concat(users.first_name," ",users.last_name) AS Name,
    SUM(order_items.item_total) AS total_revenue,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(order_items.quantity) AS total_quantity,
    users.signup_date,
    users.country
FROM orders
JOIN order_items 
    ON orders.order_id = order_items.order_id
JOIN users
    ON orders.user_id = users.user_id
GROUP BY 
    orders.user_id, 
    users.signup_date, 
    users.country
ORDER BY total_revenue DESC
LIMIT 10;

-- 12. IS THERE ANY PRODUCTS WITH NO SALES
SELECT 
    products.product_id,
    products.product_name,
    products.category
FROM products
LEFT JOIN order_items 
    ON products.product_id = order_items.product_id
WHERE order_items.product_id IS NULL;

-- 13. COUNTS OF PRODUCTS AND REVENUE BY CATEGORY
SELECT 
    products.category,
    COUNT(DISTINCT products.product_id) AS product_count,
    SUM(order_items.item_total) AS revenue
FROM products
LEFT JOIN order_items 
    ON products.product_id = order_items.product_id
GROUP BY products.category
ORDER BY revenue DESC;

-- 14. TOP 10 PRODUCTS BY REVENUE
SELECT 
    products.product_id,
    products.product_name,
    products.category,
    SUM(order_items.item_total) AS revenue,
    SUM(order_items.quantity) AS quantity_sold
FROM products
JOIN order_items 
    ON products.product_id = order_items.product_id
GROUP BY products.product_id, products.product_name, products.category
ORDER BY revenue DESC
LIMIT 10;

-- 15. BOTTOM 10 PRODUCTS BY QUANTITY SOLD
SELECT 
    products.product_id,
    products.product_name,
    products.category,
    COALESCE(SUM(order_items.quantity), 0) AS quantity_sold
FROM products
LEFT JOIN order_items
    ON products.product_id = order_items.product_id
GROUP BY 
    products.product_id
ORDER BY quantity_sold ASC
LIMIT 10;

-- 16. SHOW THE INVENTORY OVERVIEW
SELECT 
    products.product_id,
    products.product_name,
    products.category,
    COALESCE(SUM(order_items.quantity), 0) AS sold_qty,
    products.inventory AS remaining_inventory
FROM products
LEFT JOIN order_items
    ON products.product_id = order_items.product_id
GROUP BY 
    products.product_id,
    products.product_name,
    products.category,
    products.inventory
    ORDER BY products.inventory asc,sold_qty desc;
    
-- 17. ORDERS PER MONTH, YEAR
SELECT 
    DATE_FORMAT(orders.order_datetime, '%Y-%m') AS month_,
    COUNT(orders.order_id) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(orders.order_datetime, '%Y-%m')
ORDER BY month_;
SELECT 
    YEAR(orders.order_datetime) AS year,
    COUNT(orders.order_id) AS total_orders
FROM orders
GROUP BY YEAR(orders.order_datetime)
ORDER BY year;

-- 18. ORDER VALUE (AOV) — PER YEAR & MONTH
SELECT 
    YEAR(orders.order_datetime) AS year,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(order_items.item_total) AS total_revenue,
    (SUM(order_items.item_total) / COUNT(DISTINCT orders.order_id)) AS AOV
FROM orders
JOIN order_items
    ON orders.order_id = order_items.order_id
GROUP BY YEAR(orders.order_datetime)
ORDER BY year;

SELECT 
	DATE_FORMAT(orders.order_datetime, '%Y-%m') AS year__month,
    COUNT(DISTINCT orders.order_id) AS total_orders,
    SUM(order_items.item_total) AS total_revenue,
    (SUM(order_items.item_total) / COUNT(DISTINCT orders.order_id)) AS AOV
FROM orders
JOIN order_items
    ON orders.order_id = order_items.order_id
GROUP BY DATE_FORMAT(orders.order_datetime, '%Y-%m')
ORDER BY year__month;

-- 19. ORDER STATUS BREAKDOWN
SELECT 
    orders.order_status,
    COUNT(*) AS status_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders)), 2) AS percentage
FROM orders
GROUP BY orders.order_status
ORDER BY status_count DESC;

-- 20. TOP RETURNED PRODUCTS
SELECT
    products.product_id,
    products.product_name,
    products.category,
    SUM(orders.order_status = 'returned') AS return_count,
    COUNT(*) AS total_orders,
    ROUND(SUM(orders.order_status = 'returned') / COUNT(*) * 100, 2) AS return_rate
FROM order_items
JOIN orders
    ON order_items.order_id = orders.order_id
JOIN products
    ON order_items.product_id = products.product_id
GROUP BY
    products.product_id,
    products.product_name,
    products.category
HAVING return_count > 0
ORDER BY return_rate DESC
LIMIT 10;

-- 21. MOST USED PAYMENT METHODS
SELECT 
    orders.payment_method,
    COUNT(*) AS usage_count,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders)), 2) AS percentage
FROM orders
GROUP BY orders.payment_method
ORDER BY usage_count DESC;

-- 22. TOP 10 PRODUCTS BY DISCOUNT PERCENTAGE
SELECT 
    products.product_id,
    products.product_name,
    products.category,
    SUM(order_items.discount) AS total_discount_given,
    SUM(order_items.item_total) AS total_revenue,
    SUM(order_items.quantity) AS total_quantity_sold,
    ROUND(
        SUM(order_items.discount) /
        (SUM(order_items.item_total) + SUM(order_items.discount)) * 100,
        2
    ) AS discount_percentage
FROM order_items
JOIN products
    ON order_items.product_id = products.product_id
GROUP BY 
    products.product_id
ORDER BY discount_percentage DESC
LIMIT 10;

-- 23. CITIES WITH MOST DELIVERIES
SELECT 
	orders.shipping_country,
    orders.shipping_city,
    COUNT(*) AS delivered_count
FROM orders
WHERE orders.order_status = 'delivered'
GROUP BY orders.shipping_city,
orders.shipping_country
ORDER BY delivered_count DESC
LIMIT 10;

-- 24. BEST RATED PRODUCT IN EACH CATEGORY
WITH prod_avg AS (
    SELECT 
        products.category,
        products.product_id,
        products.product_name,
        AVG(reviews.rating) AS avg_rating
    FROM reviews
    JOIN products
        ON reviews.product_id = products.product_id
    GROUP BY 
        products.category,
        products.product_id,
        products.product_name
)
SELECT *
FROM prod_avg p
WHERE p.avg_rating = (
    SELECT MAX(avg_rating)
    FROM prod_avg
    WHERE category = p.category
)
ORDER BY p.category;

-- 25. OVERALL TOP RATED PRODUCTS
SELECT
    products.product_id,
    products.product_name,
    products.category,
    AVG(reviews.rating) AS avg_rating,
    COUNT(reviews.rating) AS rating_count
FROM reviews
JOIN products
    ON reviews.product_id = products.product_id
GROUP BY
    products.product_id,
    products.product_name,
    products.category
ORDER BY
    avg_rating DESC,
    rating_count DESC
LIMIT 10;

-- 26. PRODUCT WITH HIGH AVG RATING BUT LOW SALES
SELECT
    products.product_id,
    products.product_name,
    products.category,
    AVG(reviews.rating) AS avg_rating,
    COUNT(reviews.rating) AS rating_count,
    COALESCE(SUM(order_items.quantity), 0) AS total_quantity_sold
FROM products
JOIN reviews
    ON products.product_id = reviews.product_id
LEFT JOIN order_items
    ON products.product_id = order_items.product_id
GROUP BY
    products.product_id,
    products.product_name,
    products.category
HAVING 
    AVG(reviews.rating) >= 4.5          -- high rating
    AND COALESCE(SUM(order_items.quantity), 0) < 20   -- low sales
ORDER BY avg_rating DESC, total_quantity_sold ASC;



