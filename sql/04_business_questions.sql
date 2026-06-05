-- ─────────────────────────────────────────────
-- Script 04: Business Questions
-- Value tiers, declining customers,
-- purchase cycle, acquisition, retention rate,
-- order size analysis
-- ─────────────────────────────────────────────

USE retail_analytics;

-- Query 1: Revenue by Customer Value Tier
WITH customer_metrics AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_id)              AS total_orders,
        ROUND(SUM(revenue), 2)                  AS total_revenue
    FROM vw_clean_transactions
    GROUP BY customer_id
),
customer_tiered AS (
    SELECT
        customer_id,
        total_orders,
        total_revenue,
        CASE
            WHEN total_revenue >= 10000 THEN '1_High Value'
            WHEN total_revenue >= 1000  THEN '2_Mid Value'
            WHEN total_revenue >= 100   THEN '3_Low Value'
            ELSE                             '4_Marginal'
        END AS value_tier
    FROM customer_metrics
)
SELECT
    value_tier,
    COUNT(customer_id)                              AS customer_count,
    ROUND(COUNT(customer_id) * 100.0 /
        SUM(COUNT(customer_id)) OVER(), 2)          AS pct_of_customers,
    ROUND(SUM(total_revenue), 2)                    AS tier_revenue,
    ROUND(SUM(total_revenue) * 100.0 /
        SUM(SUM(total_revenue)) OVER(), 2)          AS pct_of_revenue,
    ROUND(AVG(total_revenue), 2)                    AS avg_revenue_per_customer,
    ROUND(AVG(total_orders), 1)                     AS avg_orders_per_customer
FROM customer_tiered
GROUP BY value_tier
ORDER BY value_tier;

-- Query 2: Customers Showing Declining Behavior (Active H1, Gone H2)
WITH h1_customers AS (
    SELECT DISTINCT customer_id FROM vw_clean_transactions
    WHERE invoice_date BETWEEN '2010-12-01' AND '2011-05-31'
),
h2_customers AS (
    SELECT DISTINCT customer_id FROM vw_clean_transactions
    WHERE invoice_date BETWEEN '2011-06-01' AND '2011-12-09'
),
h1_revenue AS (
    SELECT customer_id,
           ROUND(SUM(revenue), 2)      AS h1_revenue,
           COUNT(DISTINCT invoice_id)  AS h1_orders
    FROM vw_clean_transactions
    WHERE invoice_date BETWEEN '2010-12-01' AND '2011-05-31'
    GROUP BY customer_id
)
SELECT
    h1.customer_id,
    hr.h1_revenue,
    hr.h1_orders,
    'Declining - Not seen in H2' AS behavior_flag
FROM h1_customers h1
LEFT JOIN h2_customers h2 ON h1.customer_id = h2.customer_id
JOIN h1_revenue hr ON h1.customer_id = hr.customer_id
WHERE h2.customer_id IS NULL
ORDER BY hr.h1_revenue DESC
LIMIT 20;

-- Query 3: Average Purchase Cycle
WITH customer_invoices AS (
    SELECT customer_id, invoice_id,
           DATE(MIN(invoice_date)) AS invoice_date
    FROM vw_clean_transactions
    GROUP BY customer_id, invoice_id
),
invoice_gaps AS (
    SELECT
        customer_id,
        DATEDIFF(invoice_date,
            LAG(invoice_date) OVER (
                PARTITION BY customer_id ORDER BY invoice_date ASC
            )) AS days_since_last_order
    FROM customer_invoices
)
SELECT
    ROUND(AVG(days_since_last_order), 0)    AS avg_days_between_orders,
    MIN(days_since_last_order)              AS min_days,
    MAX(days_since_last_order)              AS max_days,
    COUNT(DISTINCT customer_id)             AS customers_with_repeat_orders
FROM invoice_gaps
WHERE days_since_last_order IS NOT NULL AND days_since_last_order > 0;

-- Query 4: Monthly New Customer Acquisition
WITH first_purchase AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m') AS acquisition_month
    FROM vw_clean_transactions
    GROUP BY customer_id
)
SELECT
    acquisition_month,
    COUNT(customer_id)                              AS new_customers_acquired,
    SUM(COUNT(customer_id)) OVER (
        ORDER BY acquisition_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                               AS cumulative_customers
FROM first_purchase
GROUP BY acquisition_month
ORDER BY acquisition_month;

-- Query 5: Monthly Repeat Purchase Rate
WITH customer_months AS (
    SELECT customer_id,
           DATE_FORMAT(invoice_date, '%Y-%m')       AS active_month
    FROM vw_clean_transactions
    GROUP BY customer_id, DATE_FORMAT(invoice_date, '%Y-%m')
),
month_retention AS (
    SELECT
        cm1.active_month                            AS current_month,
        COUNT(DISTINCT cm1.customer_id)             AS active_customers,
        COUNT(DISTINCT cm2.customer_id)             AS returned_next_month
    FROM customer_months cm1
    LEFT JOIN customer_months cm2
        ON cm1.customer_id = cm2.customer_id
        AND DATE_FORMAT(DATE_ADD(
                STR_TO_DATE(CONCAT(cm1.active_month, '-01'), '%Y-%m-%d'),
                INTERVAL 1 MONTH), '%Y-%m') = cm2.active_month
    GROUP BY cm1.active_month
)
SELECT
    current_month,
    active_customers,
    returned_next_month,
    ROUND(returned_next_month * 100.0 / active_customers, 2) AS retention_rate_pct
FROM month_retention
ORDER BY current_month;

-- Query 6: Order Size Distribution
WITH order_values AS (
    SELECT invoice_id, customer_id,
           ROUND(SUM(revenue), 2) AS order_value
    FROM vw_clean_transactions
    GROUP BY invoice_id, customer_id
)
SELECT
    CASE
        WHEN order_value >= 1000 THEN '5. £1000+'
        WHEN order_value >= 500  THEN '4. £500-999'
        WHEN order_value >= 200  THEN '3. £200-499'
        WHEN order_value >= 50   THEN '2. £50-199'
        ELSE                          '1. Under £50'
    END                                             AS order_size_bucket,
    COUNT(invoice_id)                               AS number_of_orders,
    ROUND(COUNT(invoice_id) * 100.0 /
        SUM(COUNT(invoice_id)) OVER(), 2)           AS pct_of_orders,
    ROUND(SUM(order_value), 2)                      AS total_revenue,
    ROUND(AVG(order_value), 2)                      AS avg_order_value,
    ROUND(SUM(order_value) * 100.0 /
        SUM(SUM(order_value)) OVER(), 2)            AS pct_of_revenue
FROM order_values
GROUP BY order_size_bucket
ORDER BY order_size_bucket;
