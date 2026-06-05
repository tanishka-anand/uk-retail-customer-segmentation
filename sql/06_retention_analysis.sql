-- ─────────────────────────────────────────────
-- Script 06: Customer Retention Analysis
-- Classifies customers monthly as
-- New / Retained / Reactivated
-- Also calculates churn rate and lifetime
-- ─────────────────────────────────────────────

USE retail_analytics;

-- Query 1: Monthly Customer Status Classification
WITH customer_months AS (
    SELECT customer_id,
           DATE_FORMAT(invoice_date, '%Y-%m-01') AS active_month
    FROM vw_clean_transactions
    GROUP BY customer_id, DATE_FORMAT(invoice_date, '%Y-%m-01')
),
first_purchase AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m-01') AS first_month
    FROM vw_clean_transactions
    GROUP BY customer_id
),
customer_status AS (
    SELECT cm.customer_id, cm.active_month, fp.first_month,
           TIMESTAMPDIFF(MONTH,
               LAG(cm.active_month) OVER (
                   PARTITION BY cm.customer_id ORDER BY cm.active_month),
               cm.active_month) AS months_since_last_active
    FROM customer_months cm
    JOIN first_purchase fp ON cm.customer_id = fp.customer_id
),
status_labeled AS (
    SELECT customer_id, active_month, first_month, months_since_last_active,
           CASE
               WHEN active_month = first_month          THEN 'New'
               WHEN months_since_last_active = 1        THEN 'Retained'
               WHEN months_since_last_active > 1        THEN 'Reactivated'
               ELSE 'Unknown'
           END AS customer_status
    FROM customer_status
)
SELECT active_month, customer_status,
       COUNT(DISTINCT customer_id) AS customer_count
FROM status_labeled
GROUP BY active_month, customer_status
ORDER BY active_month ASC, customer_status ASC;

-- Query 2: Overall Retention Health Scorecard
WITH customer_months AS (
    SELECT customer_id,
           DATE_FORMAT(invoice_date, '%Y-%m-01') AS active_month
    FROM vw_clean_transactions
    GROUP BY customer_id, DATE_FORMAT(invoice_date, '%Y-%m-01')
),
first_purchase AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m-01') AS first_month
    FROM vw_clean_transactions GROUP BY customer_id
),
customer_status AS (
    SELECT cm.customer_id, cm.active_month, fp.first_month,
           TIMESTAMPDIFF(MONTH,
               LAG(cm.active_month) OVER (
                   PARTITION BY cm.customer_id ORDER BY cm.active_month),
               cm.active_month) AS months_since_last_active
    FROM customer_months cm
    JOIN first_purchase fp ON cm.customer_id = fp.customer_id
),
status_labeled AS (
    SELECT customer_id, active_month,
           CASE
               WHEN active_month = first_month          THEN 'New'
               WHEN months_since_last_active = 1        THEN 'Retained'
               WHEN months_since_last_active > 1        THEN 'Reactivated'
               ELSE 'Unknown'
           END AS customer_status
    FROM customer_status
)
SELECT
    customer_status,
    COUNT(*)                                            AS total_occurrences,
    COUNT(DISTINCT customer_id)                         AS unique_customers,
    ROUND(COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(), 2)                        AS pct_of_all_activity
FROM status_labeled
GROUP BY customer_status
ORDER BY total_occurrences DESC;

-- Query 3: Customer Lifetime Distribution
WITH customer_lifetime AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_id)                      AS total_orders,
        ROUND(SUM(revenue), 2)                          AS total_revenue,
        DATEDIFF(MAX(invoice_date), MIN(invoice_date))  AS lifespan_days
    FROM vw_clean_transactions
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN lifespan_days = 0      THEN '1. Single day'
        WHEN lifespan_days <= 30    THEN '2. Under 1 month'
        WHEN lifespan_days <= 90    THEN '3. 1-3 months'
        WHEN lifespan_days <= 180   THEN '4. 3-6 months'
        WHEN lifespan_days <= 270   THEN '5. 6-9 months'
        WHEN lifespan_days <= 365   THEN '6. 9-12 months'
        ELSE                             '7. Over 12 months'
    END                                                 AS lifespan_bucket,
    COUNT(customer_id)                                  AS customer_count,
    ROUND(COUNT(customer_id) * 100.0 /
        SUM(COUNT(customer_id)) OVER(), 2)              AS pct_of_customers,
    ROUND(AVG(total_revenue), 2)                        AS avg_revenue,
    ROUND(AVG(total_orders), 1)                         AS avg_orders
FROM customer_lifetime
GROUP BY lifespan_bucket
ORDER BY lifespan_bucket;
