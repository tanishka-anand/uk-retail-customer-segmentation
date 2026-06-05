-- ─────────────────────────────────────────────
-- Script 02: Data Cleaning
-- Creates cleaned view with business justifications
-- ─────────────────────────────────────────────

USE retail_analytics;

-- Step 1: Data Quality Audit
SELECT
    COUNT(*)                                                        AS total_raw_rows,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)           AS null_customer_id,
    SUM(CASE WHEN invoice_id LIKE 'C%' THEN 1 ELSE 0 END)          AS cancellations,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END)                 AS negative_quantity,
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END)                    AS zero_or_neg_price,
    SUM(CASE WHEN country != 'United Kingdom' THEN 1 ELSE 0 END)   AS non_uk_rows,
    SUM(CASE WHEN invoice_date < '2010-12-01' THEN 1 ELSE 0 END)   AS outside_date_range
FROM transactions;

-- Step 2: Create Cleaned View
DROP VIEW IF EXISTS vw_clean_transactions;

CREATE VIEW vw_clean_transactions AS
SELECT
    id,
    invoice_id,
    stock_code,
    description,
    quantity,
    invoice_date,
    price,
    customer_id,
    country,
    ROUND(quantity * price, 2) AS revenue
FROM transactions
WHERE
    customer_id     IS NOT NULL
    AND invoice_id  NOT LIKE 'C%'
    AND quantity    > 0
    AND price       > 0
    AND country     = 'United Kingdom'
    AND invoice_date >= '2010-12-01';

-- Step 3: Cleaning Summary
SELECT
    (SELECT COUNT(*) FROM transactions)             AS raw_rows,
    (SELECT COUNT(*) FROM vw_clean_transactions)    AS clean_rows,
    (SELECT COUNT(*) FROM transactions) -
    (SELECT COUNT(*) FROM vw_clean_transactions)    AS rows_removed,
    ROUND(
        (SELECT COUNT(*) FROM vw_clean_transactions) * 100.0 /
        (SELECT COUNT(*) FROM transactions)
    , 2)                                            AS pct_data_retained;

-- Step 4: Verify Clean View
SELECT COUNT(DISTINCT customer_id)     AS unique_customers FROM vw_clean_transactions;
SELECT ROUND(SUM(revenue), 2)          AS total_revenue_gbp FROM vw_clean_transactions;
SELECT MIN(invoice_date) AS earliest, MAX(invoice_date) AS latest FROM vw_clean_transactions;
