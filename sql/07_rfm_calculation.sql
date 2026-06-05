-- ─────────────────────────────────────────────
-- Script 07: RFM Calculation
-- Scores every customer 1-5 on Recency,
-- Frequency, Monetary
-- Reference date: 2011-12-10
-- ─────────────────────────────────────────────

USE retail_analytics;

-- Step 1: Full RFM Scoring with Segment Labels
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF('2011-12-10', MAX(DATE(invoice_date)))  AS recency_days,
        COUNT(DISTINCT invoice_id)                        AS frequency,
        ROUND(SUM(revenue), 2)                            AS monetary
    FROM vw_clean_transactions
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id, recency_days, frequency, monetary,
        6 - NTILE(5) OVER (ORDER BY recency_days ASC)    AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)           AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)            AS m_score
    FROM rfm_base
),
rfm_combined AS (
    SELECT
        customer_id, recency_days, frequency, monetary,
        r_score, f_score, m_score,
        CONCAT(r_score, f_score, m_score)                AS rfm_score,
        ROUND((r_score*0.4)+(f_score*0.3)+(m_score*0.3),2) AS rfm_weighted_score
    FROM rfm_scores
),
rfm_segmented AS (
    SELECT
        customer_id, recency_days, frequency, monetary,
        r_score, f_score, m_score, rfm_score, rfm_weighted_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4
             AND m_score >= 4                    THEN 'Champion'
            WHEN f_score >= 3 AND m_score >= 3
             AND r_score >= 3                    THEN 'Loyal Customer'
            WHEN r_score >= 4 AND f_score <= 3   THEN 'Potential Loyalist'
            WHEN r_score <= 2 AND f_score >= 3
             AND m_score >= 3                    THEN 'At Risk'
            WHEN r_score >= 3 AND f_score <= 2
             AND m_score <= 2                    THEN 'Promising'
            WHEN r_score >= 3 AND f_score >= 2
             AND m_score >= 2                    THEN 'Needs Attention'
            WHEN r_score <= 3 AND f_score <= 2   THEN 'About to Sleep'
            WHEN r_score <= 2 AND f_score <= 2   THEN 'Lost'
            ELSE                                      'Needs Attention'
        END AS segment_name
    FROM rfm_combined
)
SELECT
    customer_id, recency_days, frequency, monetary,
    r_score, f_score, m_score, rfm_score, rfm_weighted_score, segment_name
FROM rfm_segmented
ORDER BY rfm_weighted_score DESC, monetary DESC;

-- Step 2: Segment Summary
WITH rfm_base AS (
    SELECT
        customer_id,
        DATEDIFF('2011-12-10', MAX(DATE(invoice_date)))  AS recency_days,
        COUNT(DISTINCT invoice_id)                        AS frequency,
        ROUND(SUM(revenue), 2)                            AS monetary
    FROM vw_clean_transactions
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT customer_id, recency_days, frequency, monetary,
        6 - NTILE(5) OVER (ORDER BY recency_days ASC)    AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)           AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)            AS m_score
    FROM rfm_base
),
rfm_combined AS (
    SELECT customer_id, recency_days, frequency, monetary,
        r_score, f_score, m_score,
        CONCAT(r_score, f_score, m_score) AS rfm_score
    FROM rfm_scores
),
rfm_segmented AS (
    SELECT customer_id, recency_days, frequency, monetary,
        r_score, f_score, m_score, rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion'
            WHEN f_score >= 3 AND m_score >= 3 AND r_score >= 3 THEN 'Loyal Customer'
            WHEN r_score >= 4 AND f_score <= 3                  THEN 'Potential Loyalist'
            WHEN r_score <= 2 AND f_score >= 3 AND m_score >= 3 THEN 'At Risk'
            WHEN r_score >= 3 AND f_score <= 2 AND m_score <= 2 THEN 'Promising'
            WHEN r_score >= 3 AND f_score >= 2 AND m_score >= 2 THEN 'Needs Attention'
            WHEN r_score <= 3 AND f_score <= 2                  THEN 'About to Sleep'
            WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost'
            ELSE                                                      'Needs Attention'
        END AS segment_name
    FROM rfm_combined
)
SELECT
    segment_name,
    COUNT(customer_id)                              AS customer_count,
    ROUND(COUNT(customer_id)*100.0/
        SUM(COUNT(customer_id)) OVER(),2)           AS pct_of_customers,
    ROUND(AVG(recency_days),0)                      AS avg_recency_days,
    ROUND(AVG(frequency),1)                         AS avg_frequency,
    ROUND(AVG(monetary),2)                          AS avg_monetary,
    ROUND(SUM(monetary),2)                          AS total_segment_revenue,
    ROUND(SUM(monetary)*100.0/
        SUM(SUM(monetary)) OVER(),2)                AS pct_of_revenue
FROM rfm_segmented
GROUP BY segment_name
ORDER BY total_segment_revenue DESC;
