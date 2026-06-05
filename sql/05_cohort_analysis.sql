-- ─────────────────────────────────────────────
-- Script 05: Cohort Analysis
-- Tracks retention % per cohort per month
-- ─────────────────────────────────────────────

USE retail_analytics;

-- Long format cohort output
WITH customer_cohort AS (
    SELECT customer_id,
           DATE_FORMAT(MIN(invoice_date), '%Y-%m-01') AS cohort_month
    FROM vw_clean_transactions
    GROUP BY customer_id
),
customer_activity AS (
    SELECT t.customer_id,
           DATE_FORMAT(t.invoice_date, '%Y-%m-01')    AS activity_month
    FROM vw_clean_transactions t
    GROUP BY t.customer_id, DATE_FORMAT(t.invoice_date, '%Y-%m-01')
),
cohort_index AS (
    SELECT ca.customer_id, cc.cohort_month, ca.activity_month,
           TIMESTAMPDIFF(MONTH, cc.cohort_month, ca.activity_month) AS month_index
    FROM customer_activity ca
    JOIN customer_cohort cc ON ca.customer_id = cc.customer_id
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_cohort
    GROUP BY cohort_month
),
cohort_retention AS (
    SELECT cohort_month, month_index,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM cohort_index
    GROUP BY cohort_month, month_index
)
SELECT
    cr.cohort_month,
    cs.cohort_customers,
    cr.month_index,
    cr.active_customers,
    ROUND(cr.active_customers * 100.0 / cs.cohort_customers, 1) AS retention_pct
FROM cohort_retention cr
JOIN cohort_size cs ON cr.cohort_month = cs.cohort_month
WHERE cr.month_index <= 12
ORDER BY cr.cohort_month ASC, cr.month_index ASC;
