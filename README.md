# 📊 SaaS Metrics Intelligence Dashboard

**A full-stack revenue analytics case study** — from synthetic data generation and SQL modeling to Python EDA and a 5-page Power BI dashboard tracking MRR, churn, customer economics, and marketing efficiency for a simulated SaaS business.

![Power BI](https://img.shields.io/badge/Power%20BI-DAX%20%7C%20Power%20Query-yellow?style=flat-square&logo=powerbi)
![SQL](https://img.shields.io/badge/SQL-MS%20SQL%20Server-blue?style=flat-square&logo=microsoftsqlserver)
![Python](https://img.shields.io/badge/Python-Pandas%20%7C%20Matplotlib%20%7C%20Seaborn-blue?style=flat-square&logo=python)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=flat-square)

---

## 🧭 Overview

This project simulates a SaaS company's revenue operations data — **5,000 customers** across 5 relational tables — and builds an end-to-end analytics pipeline to answer the questions a SaaS finance/growth team actually asks:

- How is **recurring revenue** trending, and where is it coming from?
- What is driving **churn**, and which segments are most at risk?
- Is **customer acquisition** efficient relative to lifetime value?
- Which **plans, industries, and channels** are the healthiest revenue engines?

The deliverable is a **5-page interactive Power BI dashboard**, backed by a documented SQL data model and a full Python-based exploratory data analysis, with a corrected and validated DAX measure library.

---

## 🖥️ Dashboard Preview

| Page | Focus |
|---|---|
| **Executive Overview** | Company-wide health snapshot for leadership |
| **Revenue Analytics** | MRR/ARR trends, MRR bridge, plan & industry revenue mix |
| **Customer Analytics** | Acquisition, LTV, tenure, and segment-level value |
| **Subscription Health** | Active/new/churned subscriptions, renewal rate, plan mix |
| **Marketing Analytics** | CAC, LTV:CAC, payback period, channel ROI |

> Screenshots of all 5 pages are available in [`/screenshots`](./screenshots).

---

## 🚀 Key Features

- **5-page Power BI report** with cross-filtering by Country, Industry, Year, and Plan
- **50+ validated DAX measures** across revenue, subscription, customer, and marketing domains
- **Corrected DAX logic** for previously broken/misleading measures (see [Data Quality & Fixes](#-data-quality--fixes))
- **Synthetic but realistic dataset** — 5,000 customers, 12-month history, 5 relational CSV tables
- **Full Python EDA** covering distribution checks, cohort trends, and churn/revenue correlations
- **SQL data model** with clean star-schema-style joins and explicit NULL handling
- Deliberately **corporate/light aesthetic** (rather than dark-themed) to demonstrate design range across audiences

---

## 🧱 Tech Stack

| Layer | Tools |
|---|---|
| Data Generation & Modeling | Python (Faker/NumPy/Pandas), MS SQL Server |
| Data Cleaning & EDA | Python (Pandas, Matplotlib, Seaborn) |
| Data Transformation | Power Query (M) |
| Semantic Layer | DAX |
| Visualization | Power BI Desktop |

---

## 🗂️ Dataset

Synthetic data was generated to mimic real SaaS billing and CRM exports:

| Table | Description | Approx. Rows |
|---|---|---|
| `customers.csv` | Customer master — signup date, industry, company size, country | 5,000 |
| `subscriptions.csv` | Subscription-level records — plan, status, start/end dates | 5,000 |
| `monthly_revenue.csv` | Monthly recurring revenue transactions per customer | 68,490 |
| `marketing_spend.csv` | Monthly spend and new customers by acquisition channel | 180 |
| `subscription_events.csv` | Churn/downgrade/upgrade and subscription events with event type | 10,707 |

---

## 📈 Headline Metrics (as modeled)

**Executive Overview**
- Total MRR: **$1.5M** · ARR: **$17.6M**
- Active Customers: **5,000** · Customer Churn: **15.5%**
- Average Customer LTV: **$3,712** · Avg CAC: **$634**

**Revenue**
- MRR YoY Growth: **66.1%**
- Expansion MRR: **$146.3K** · Churned MRR: **$201.8K**

**Customers**
- New Customers: **1,734** · Avg Revenue/Customer: **$294**
- Avg Customer Tenure: **14 months**

**Subscriptions**
- Active Subscriptions: **3,374** · Renewal Rate: **84.5%**
- Net Subscription Growth: **+960**

**Marketing**
- CAC: **$634** · CAC Payback Period: **2.2 months**
- LTV:CAC and Acquisition Efficiency: **5.9x**

---

## 🛠️ Data Quality & Fixes

A DAX audit surfaced two critical measure bugs that were corrected before finalizing the report:

1. **MRR inflated ~10x** — traced to a summation error double-aggregating across an unfiltered date table relationship; corrected with proper `CALCULATE` filter context.
2. **Broken MRR Growth Rate measure** — was returning static/incorrect values due to a missing time-intelligence function; rebuilt using `DIVIDE` and prior-period comparison logic to return accurate MoM/YoY growth.

The corrected, validated measures are documented in the DAX measure library included in this repo.

---

## 📁 Project Structure

```
saas-metrics-intelligence-dashboard/
├── data/
│   ├── customers.csv
│   ├── subscriptions.csv
│   ├── revenue.csv
│   ├── marketing_spend.csv
│   └── churn_events.csv
├── sql/
│   └── data_model.sql          # DDL, joins, NULL handling
├── python/
│   └── saas_eda.py             # Exploratory data analysis
├── powerbi/
│   ├── SaaS_Metrics_Dashboard.pbix
│   └── dax_measures_library.md
├── screenshots/
│   ├── executive_overview.png
│   ├── revenue_analytics.png
│   ├── customer_analytics.png
│   ├── subscription_health.png
│   └── marketing_analytics.png
└── README.md
```

---

## 🔍 Exploratory Data Analysis (Python)

`saas_eda.py` covers:
- Data integrity checks (nulls, duplicates, referential consistency across tables)
- Revenue and subscription trend analysis over the 12-month window
- Churn rate breakdowns by plan, country, and industry
- Customer LTV and CAC payback distributions
- Visualizations built with Matplotlib/Seaborn to validate patterns before they were rebuilt as DAX measures in Power BI

---

## 🧮 SQL Layer

The SQL layer (MS SQL Server) handles:
- Table creation and constraints for all 5 entities
- Explicit handling of NULLs (e.g., customers with no churn date, in-progress subscriptions)
- Joins structured to support a clean star-schema import into Power BI's data model

---

## ⚙️ How to Use

1. Clone the repo
2. Load the CSVs in `/data` into SQL Server using the schema in `sql/data_model.sql`, **or** connect Power BI directly to the CSVs
3. Open `powerbi/SaaS_Metrics_Dashboard.pbix` in Power BI Desktop
4. Refresh the data source connection to point to your local files/database
5. Run `python/saas_eda.py` (requires `pandas`, `matplotlib`, `seaborn`) to reproduce the EDA notebooks/charts

---

## 🎯 Why This Project

This project was built to demonstrate practical SaaS/subscription analytics skills — the kind used to assess revenue quality, retention health, and go-to-market efficiency — using a dataset and metric set modeled closely on real B2B SaaS reporting conventions (MRR bridges, cohort churn, CAC payback, LTV:CAC).

---

## 👤 Author

**Yusuf**
Data Analyst | SQL · Power BI · Python
📧 mdyusuf911@gmail.com
💻 [github.com/Yusufmd24](https://github.com/Yusufmd24)

---

⭐ If you found this project useful or interesting, consider giving it a star!
