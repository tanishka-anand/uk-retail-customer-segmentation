# 🛍️ UK Retail Customer Segmentation — RFM + K-Means Analysis

## 📌 Project Overview

This project is a complete end-to-end customer segmentation analysis on a 
UK-based online gift retailer with 1M+ transactions. The analysis identifies 
who the business's customers are, how they behave, and what commercial actions 
should be taken for each segment — with estimated revenue impact.

**Tools Used:** MySQL | Python | Power BI  
**Dataset:** Online Retail II — UCI Machine Learning Repository (2009–2011)  
**Role Simulated:** Data/Product Analyst — Customer Intelligence

---

## 🎯 Business Problem

A UK-based online gift retailer had zero visibility into customer behavior. 
Every customer was treated identically — same campaigns, same messaging — 
despite enormous differences in purchase frequency and spending patterns.

**Business Question:**
> "Which customers should we invest in, which should we reactivate, 
> and which should we accept as lost — and what is the estimated 
> revenue impact of acting on this?"

**Stakeholders:**
- Head of Marketing
- VP of Growth
- Commercial Director
- Finance Team

---

## 📊 Dataset Description

| Property | Detail |
|---|---|
| Source | UCI Machine Learning Repository |
| Records | 1,067,371 raw transactions |
| Clean Records | 367,685 (after scoping to UK, removing nulls/cancellations) |
| Time Period | December 2010 — December 2011 |
| Market | United Kingdom only |
| Unique Customers | 3,920 identifiable UK customers |
| Total Revenue | £7,587,047 |

**Important Note:** This is real transactional data from a live UK retailer 
exported from their system — not synthetic. Data quality issues including 
missing customer IDs, negative quantities, and cancellation invoices are 
genuine and handled with documented business justifications.

---

## 🔍 Key Findings

### Finding 1 — Extreme Revenue Concentration
- Top 20% of customers generate **73.39% of revenue**
- 530 Champions (13.5% of base) generate **62.4% of total revenue**
- Treating all customers equally is commercially irrational

### Finding 2 — Severe Retention Problem
- **34.44% of customers never returned** after first purchase
- 53% of customers placed 3 or fewer orders in 12 months
- Month 1 retention averages only 20% across all cohorts

### Finding 3 — Average Purchase Cycle is 46 Days
- Customers who returned did so every 46 days on average
- Customers inactive beyond 90 days are 2x their normal cycle
- This anchors all win-back campaign timing recommendations

### Finding 4 — December 2010 Cohort is Exceptionally Strong
- Retained 35-40% of customers consistently for 10 months
- Spiked to 49.7% in Month 11 — annual Christmas repurchase behavior
- All other cohorts show M1 retention of only 15-22%

### Finding 5 — Four Distinct Behavioral Segments Identified

| Segment | Customers | Revenue | Avg Spend | Avg Recency |
|---|---|---|---|---|
| Champions | 530 | £4,735,036 (62.4%) | £8,934 | 21 days |
| Loyal Customers | 1,323 | £2,068,040 (27.3%) | £1,563 | 47 days |
| Potential Loyalists | 1,214 | £443,829 (5.8%) | £366 | 58 days |
| Inactive | 853 | £340,142 (4.5%) | £399 | 258 days |

---

## 💡 Business Recommendations

| Segment | Action | Revenue Impact |
|---|---|---|
| Champions | VIP program + early access + referral | £236,751 |
| Loyal Customers | Frequency nudge + category expansion | £88,300 |
| Potential Loyalists | 3-email onboarding sequence within 45 days | £44,408 |
| Inactive | Single win-back on top 200 then suppress | £12,800 |
| **Total** | | **£382,259** |

**Estimated ROI: 38x** (£382,259 revenue ÷ <£10,000 implementation cost)

---

## 🛠 Technical Approach

### SQL Analysis (MySQL)
7 script files covering:
- Database setup and data loading pipeline
- Data cleaning with documented business decisions
- Exploratory analysis — Pareto, frequency distribution, revenue stats
- Business questions — purchase cycle, value tiers, declining customers
- Cohort analysis — 12-month retention grid using TIMESTAMPDIFF
- Retention analysis — monthly New/Retained/Reactivated classification
- RFM calculation — NTILE scoring, weighted RFM, segment labeling

### Python Analysis (Jupyter Notebook)
2 notebooks:
- `01_data_loading.ipynb` — Excel to MySQL pipeline using SQLAlchemy
- `02_rfm_clustering.ipynb` — Feature engineering, StandardScaler, 
  K-Means (K=4, Silhouette=0.38), cluster profiling, Power BI export

### Power BI Dashboard
4 dashboard pages:
- Executive Overview — KPIs, revenue distribution, monthly trend
- Segment Behavioral Profiles — scatter plot, matrix table, revenue chart
- Cohort Retention Analysis — heatmap, Month 1 retention line chart
- Business Recommendations — action plan, revenue impact, priority cards

---

## 📈 Dashboard Preview

### Page 1 — Executive Overview
![Executive Overview](dashboard/page1_executive_overview.png)

### Page 2 — Segment Behavioral Profiles
![Segment Profiles](dashboard/page2_segment_profiles.png)

### Page 3 — Cohort Retention Analysis
![Cohort Retention](dashboard/page3_cohort_retention.png)

### Page 4 — Business Recommendations
![Recommendations](dashboard/page4_recommendations.png)

> 📥 Download Interactive Dashboard: 
> [customer_segmentation_dashboard.pbix](dashboard/customer_segmentation_dashboard.pbix)

---

## 📁 Repository Structure
```
uk-retail-customer-segmentation/
├── README.md
├── data/
│   └── data_description.md
├── sql/
│   ├── 01_setup_and_load.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_exploratory_analysis.sql
│   ├── 04_business_questions.sql
│   ├── 05_cohort_analysis.sql
│   ├── 06_retention_analysis.sql
│   └── 07_rfm_calculation.sql
├── python/
│   ├── 01_data_loading.ipynb
│   └── 02_rfm_clustering.ipynb
├── dashboard/
│   ├── page1_executive_overview.png
│   ├── page2_segment_profiles.png
│   ├── page3_cohort_retention.png
│   ├── page4_recommendations.png
│   └── customer_segmentation_dashboard.pbix
└── docs/
└── cleaning_decisions.md
```
---

## ⚠️ Project Limitations

1. **Analysis Window** — RFM analysis covers December 2010 to December 2011 
   only. Customer behavior outside this window is not captured.

2. **UK Scope Only** — International customers (8% of raw data) excluded to 
   focus on the core market. International segment behavior not analyzed.

3. **Guest Checkouts Excluded** — 22.7% of transactions had no customer ID 
   and could not be attributed to tracked customer behavior.

4. **December 2011 Partial Month** — Dataset ends December 9, 2011. 
   The final month's figures are not comparable to full months.

5. **Static Segmentation** — RFM segments reflect behavior at a point in time. 
   Production implementation would require monthly re-scoring.

---

## 🚀 How to Reproduce

### Prerequisites
- MySQL Workbench 8.0+
- Python 3.8+ with pandas, numpy, scikit-learn, sqlalchemy, matplotlib, 
  seaborn installed
- Power BI Desktop latest version
- Dataset: [Online Retail II — UCI](https://archive.ics.uci.edu/dataset/502/online+retail+ii)

### Step 1 — Database Setup
```sql
CREATE DATABASE retail_analytics;
USE retail_analytics;
```
Then run `sql/01_setup_and_load.sql`

### Step 2 — Load Data
Run `python/01_data_loading.ipynb` in Jupyter Notebook  
Update the file path to your local Excel file location

### Step 3 — Run SQL Analysis
Run scripts 02 through 07 in order in MySQL Workbench

### Step 4 — Run Python Clustering
Run `python/02_rfm_clustering.ipynb` in Jupyter Notebook  
This generates `customer_segments_powerbi.csv`

### Step 5 — Open Power BI Dashboard
Open `dashboard/customer_segmentation_dashboard.pbix`  
If visuals do not load: Home → Transform Data → Data Source Settings  
→ update CSV file paths to your local paths

---

## 🔗 Data Source

Dataset: [Online Retail II — UCI Machine Learning Repository]
(https://archive.ics.uci.edu/dataset/502/online+retail+ii)

---

## 👤 Author

**Tanishka Anand**  
Product Analyst | Data Analyst | SQL | Python | Power BI  
tanishka.anand.27@gmail.com
