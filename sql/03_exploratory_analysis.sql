-- ─────────────────────────────────────────────
-- Script 03: Exploratory Data Analysis
-- Monthly trends, Pareto, top customers,
-- frequency distribution, revenue stats
-- ─────────────────────────────────────────────

USE retail_analytics;

-- Query 1: Monthly Revenue Trend
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m')          AS month,
    COUNT(DISTINCT invoice_id)                  AS total_invoices,
    COUNT(DISTINCT customer_id)                 AS unique_customers,
    ROUND(SUM(revenue), 2)                      AS monthly_revenue,
    ROUND(AVG(revenue), 2)                      AS avg_revenue_per_line
FROM vw_clean_transactions
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY month ASC;

-- Query 2: Pareto Analysis
WITH customer_revenue AS (
    SELECT customer_id, ROUND(SUM(revenue), 2) AS total_revenue
    FROM vw_clean_transactions
    GROUP BY customer_id
),
customer_ranked AS (
    SELECT
        customer_id,
        total_revenue,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_quintile
    FROM customer_revenue
),
quintile_summary AS (
    SELECT
        revenue_quintile,
        COUNT(customer_id)                              AS customer_count,
        ROUND(SUM(total_revenue), 2)                    AS quintile_revenue,
        ROUND(SUM(total_revenue) * 100.0 /
            SUM(SUM(total_revenue)) OVER(), 2)          AS pct_of_total_revenue
    FROM customer_ranked
    GROUP BY revenue_quintile
)
SELECT
    revenue_quintile,
    customer_count,
    quintile_revenue,
    pct_of_total_revenue,
    ROUND(SUM(pct_of_total_revenue)
        OVER (ORDER BY revenue_quintile), 2)            AS cumulative_pct
FROM quintile_summary
ORDER BY revenue_quintile;

-- Query 3: Top 20 Customers by Revenue
SELECT
    customer_id,
    COUNT(DISTINCT invoice_id)          AS total_orders,
    ROUND(SUM(revenue), 2)              AS total_revenue,
    MIN(DATE(invoice_date))             AS first_purchase,
    MAX(DATE(invoice_date))             AS last_purchase,
    DATEDIFF(MAX(invoice_date), MIN(invoice_date)) AS customer_lifespan_days
FROM vw_clean_transactions
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 20;

-- Query 4: Purchase Frequency Distribution
WITH customer_orders AS (
    SELECT customer_id, COUNT(DISTINCT invoice_id) AS order_count
    FROM vw_clean_transactions
    GROUP BY customer_id
)
SELECT
    order_count,
    COUNT(customer_id)                              AS number_of_customers,
    ROUND(COUNT(customer_id) * 100.0 /
        SUM(COUNT(customer_id)) OVER(), 2)          AS pct_of_customers
FROM customer_orders
GROUP BY order_count
ORDER BY order_count ASC
LIMIT 20;

-- Query 5: Revenue Distribution Statistics
WITH customer_revenue AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_id)      AS total_orders,
        ROUND(SUM(revenue), 2)          AS total_revenue
    FROM vw_clean_transactions
    GROUP BY customer_id
)
SELECT
    COUNT(customer_id)                                          AS total_customers,
    ROUND(MIN(total_revenue), 2)                                AS min_revenue,
    ROUND(MAX(total_revenue), 2)                                AS max_revenue,
    ROUND(AVG(total_revenue), 2)                                AS avg_revenue,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)           AS one_time_buyers,
    ROUND(SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(customer_id), 2)                        AS pct_one_time_buyers
FROM customer_revenue;

-- Query 6: Top 10 Products by Revenue
SELECT
    stock_code,
    description,
    COUNT(DISTINCT invoice_id)          AS times_ordered,
    SUM(quantity)                       AS total_units_sold,
    ROUND(SUM(revenue), 2)              AS total_revenue,
    ROUND(AVG(price), 2)                AS avg_unit_price
FROM vw_clean_transactions
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;
