# Dataset Description

**Name:** Online Retail II  
**Source:** UCI Machine Learning Repository  
**URL:** https://archive.ics.uci.edu/dataset/502/online+retail+ii  
**Format:** Excel (.xlsx) with two sheets

## Column Descriptions

| Column | Type | Description |
|---|---|---|
| Invoice | VARCHAR | Invoice number. Prefix C = cancellation |
| StockCode | VARCHAR | Product identifier |
| Description | VARCHAR | Product name (4,382 nulls) |
| Quantity | INT | Units sold. Negative = return |
| InvoiceDate | DATETIME | Transaction timestamp |
| Price | DECIMAL | Unit price in GBP |
| Customer ID | FLOAT | Customer identifier (243,007 nulls) |
| Country | VARCHAR | Customer country (43 unique) |

## Key Statistics

| Metric | Value |
|---|---|
| Total rows | 1,067,371 |
| Date range | Dec 2009 — Dec 2011 |
| Unique countries | 43 |
| UK rows | 981,330 (92%) |
| Cancellation rows | 19,494 |
| NULL customer IDs | 243,007 |
