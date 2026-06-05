# Data Cleaning Decisions

## Decision 1 — Exclude NULL Customer IDs
**Rows affected:** 243,007 (22.7% of raw data)  
**Reason:** Cannot track behavioral metrics without a customer identifier. 
These are guest checkouts or POS transactions — not trackable relationships.

## Decision 2 — Exclude Cancellation Invoices (C prefix)
**Rows affected:** 19,494  
**Reason:** Cancellations are not sales events. Including them distorts 
revenue and frequency calculations.

## Decision 3 — Exclude Negative Quantity Rows
**Rows affected:** 22,950  
**Reason:** Returns reduce revenue but do not represent purchase behavior. 
Excluded from customer-level analysis.

## Decision 4 — Exclude Zero/Negative Price Rows
**Rows affected:** 6,225  
**Reason:** Zero-price transactions represent internal stock transfers or 
samples — not real commercial sales events.

## Decision 5 — UK Customers Only
**Rows affected:** 86,041 non-UK rows excluded  
**Reason:** UK represents 92% of data and is the core market. International 
customers show different purchase patterns and would skew RFM scores.

## Decision 6 — December 2010 Onwards
**Rows affected:** 502,938 rows outside window  
**Reason:** RFM is most predictive when based on recent behavior. Most recent 
12 months balances data volume with recency relevance.

## Final Clean Dataset
| Metric | Value |
|---|---|
| Raw rows | 1,067,371 |
| Clean rows | 367,685 |
| Data retained | 34.45% |
| Unique customers | 3,920 |
| Total revenue | £7,587,047 |
