# Decoding Customer Value: A SQL-Driven Retention Strategy

A full customer analytics case study for a hypothetical D2C fashion brand — raw transaction data is cleaned and engineered into customer-level features in **Python**, queried for business answers in **SQL**, and visualized in an interactive **Power BI** dashboard built for a non-technical founding team.

**Live links:** [Colab notebook](https://colab.research.google.com/drive/1GPk25bH32LD-8zp1U0oqTPIuvRfrzcoj) · [GitHub repo](https://github.com/shiveshkumar7007/Sales_Forecasting)

\---

## The Problem

The brand has transaction data but no structured intelligence built on top of it. It can't yet answer:

* Is the discount/promo program building real loyalty, or just attracting one-time bargain hunters?
* What does the best customer actually look like — and which regions show genuine organic demand versus discount-driven volume?
* How much current revenue depends on promotions, and where is that dependency concentrated?

The goal of this project is to answer those questions with data instead of gut feel, using only behavioral and transactional signals already in the business.

\---

## Key Findings

Computed directly from `Data/customer\_features.csv` and the queries in `comprehensive\_analysis.sql`:

* **Revenue is broad-based, not top-heavy.** The top 10% of customers by spend generate only \~16% of total revenue (vs. the classic 80/20 pattern) — growth depends on the health of the whole base, not a small VIP cohort. *(Q9)*
* **Discounting isn't buying extra revenue at the top.** Among Premium Value customers, average spend is nearly identical whether they're highly promo-dependent ($91.00) or not ($91.15) — but loyalty score is \~7% higher in the non-promo-dependent group (0.544 vs 0.507). The discount is buying margin loss, not incremental sales. *(Q4)*
* **42.65% of total revenue ($99K of $233K) currently comes from Highly Promo Dependent customers** — a meaningful share of the business is propped up by discounting. *(Dashboard, confirmed via Q1/Q6)*
* **The subscription program isn't functioning as a loyalty lever yet.** Subscription rate is flat (\~27%) across every value tier, and in 3 of 4 product categories subscribed customers don't outspend non-subscribed ones — in Accessories, subscribers actually spend slightly less ($58.82 vs $60.21). *(Q2, Q14)*
* **Arizona looks like a genuine organic-demand market.** Average spend is on par with the top states ($66.55) but discount dependency is the lowest among them (0.338 vs \~0.44–0.49 elsewhere) — a candidate for pulling back promos rather than doubling down. *(Q3)*

\---

## How the Pipeline Works

Each stage answers a different question — nothing is repeated across layers:

|Stage|Tool|Question it answers|
|-|-|-|
|**1. Data prep \& feature engineering**|Python (`feature\_engineering\_pipeline.py`)|*What does the data look like, and what customer-level signals are worth measuring?* Cleans the raw transaction log, engineers 31 customer-level features (loyalty scores, value tiers, promo dependency, satisfaction flags, K-Means clusters), and exports the four tables in `Data/`.|
|**2. Business analysis**|SQL (`comprehensive\_analysis.sql`)|*What can I conclude from this data?* 15 queries, progressing from simple grouping (Q1–Q5) to window functions and multi-table joins (Q6–Q15), each tied to a specific retention or promo decision.|
|**3. Communication**|Power BI (`Sales\_Forecasting\_Dashboard.pbix`)|*How do I make this usable for a non-technical founder?* A four-panel interactive dashboard: customer value pyramid, promo dependency vs. loyalty, geographic opportunity map, and category funnel.|

\---

## Repository Structure

```
Sales\_Forecasting/
├── Data/                              Engineered tables the SQL layer queries
│   ├── customer\_features.csv          3,900 rows × 31 cols — one row per customer:
│   │                                  engineered metrics, loyalty scores, value tier,
│   │                                  promo dependency segment, customer segment, cluster
│   ├── category\_analysis.csv          Category-level benchmarks (avg spend/rating/purchases) — joined in Q13
│   ├── geography\_analysis.csv         State-level benchmarks (avg spend/loyalty/discount dependency) — joined in Q12
│   └── segment\_analysis.csv           Segment-level benchmarks (avg spend/loyalty) — joined in Q11
│
├── Results/                           One CSV per SQL business question (Q1–Q15)
│   ├── q1\_loyal\_vs\_discount.csv
│   ├── q2\_behavioral\_patterns.csv
│   └── ...                            q3 – q15, matching the queries in comprehensive\_analysis.sql
│
├── Dataset.csv                        Raw source data — 3,900 rows × 18 columns (see Data Source below)
├── feature\_engineering\_pipeline.py    Python: cleaning, EDA, feature engineering, loyalty scoring,
│                                      segmentation, K-Means clustering (Colab-exported)
├── comprehensive\_analysis.sql         All 15 business questions as MySQL queries, simple → advanced
├── Sales\_Forecasting\_Dashboard.pbix   Interactive Power BI dashboard (open in Power BI Desktop)
├── Sales\_Forecasting\_Dashboard.pdf    Static export of the dashboard, for a quick preview without Power BI
└── README.md
```

\---

## Data Source

Raw data: [Customer Shopping Trends Dataset — Kaggle](https://www.kaggle.com/datasets/iamsouravbanerjee/customer-shopping-trends-dataset/), 3,900 transaction-level rows across 18 columns (age, category, purchase amount, location, review rating, subscription status, payment method, shipping type, discount/promo usage, purchase frequency, etc.).

For this case study, the dataset is reframed as behavioral history for a hypothetical direct-to-consumer fashion brand. `feature\_engineering\_pipeline.py` aggregates the transaction-level rows up to one row per customer (31 engineered columns) in `customer\_features.csv`, which is what every SQL query and the Power BI dashboard run against.

\---

## Business Questions Answered

**Section A — Basic Customer Profiling**

|#|Question|
|-|-|
|1|Loyal vs. discount-only customers|
|2|Behavioral patterns that predict high value|
|3|Geographically underleveraged markets|
|4|Restructuring the promotional strategy|
|5|Ideal Customer Profile (ICP) extraction|

**Section B — Advanced Business Problems**

|#|Question|
|-|-|
|6|Promo margin leakage \& profit-at-risk analysis|
|7|Cross-sell \& category expansion matrix|
|8|"At-risk" high-value churn prediction profiler|
|9|Cumulative revenue concentration (decile Pareto analysis)|
|10|Multi-channel preference optimization|
|11|Segment benchmark variance analysis (join with `segment\_analysis`)|
|12|Geographic efficiency vs. state benchmark comparison (join with `geography\_analysis`)|
|13|Category expectation vs. reality check (join with `category\_analysis`)|
|14|Subscription revenue premium analysis|
|15|High-frequency shipping drain identification|

Full query logic for every question is in `comprehensive\_analysis.sql`; outputs are saved individually in `Results/`.

\---

## Explore It Yourself

* **Notebook:** open the [Colab link](https://colab.research.google.com/drive/1GPk25bH32LD-8zp1U0oqTPIuvRfrzcoj) and run top to bottom, or run `feature\_engineering\_pipeline.py` locally against `Dataset.csv`.
* **SQL:** load the four CSVs in `Data/` as tables (`customer\_features`, `segment\_analysis`, `geography\_analysis`, `category\_analysis`) into MySQL or any SQL engine, then run `comprehensive\_analysis.sql`.
* **Dashboard:** open `Sales\_Forecasting\_Dashboard.pbix` in Power BI Desktop for the interactive version, or view `Sales\_Forecasting\_Dashboard.pdf` for a static preview.

\---

## Tech Stack

Python (pandas, numpy, scikit-learn, matplotlib, seaborn) · SQL (MySQL) · Power BI · Google Colab

