# SaaS Metrics Intelligence Dashboard — Complete DAX Measure Library

**Model:** `SaaS_Analytics_Dashboard`
**Total measures:** 54, across 5 measure tables
**Source data:** `customers`, `subscriptions`, `subscription_events`, `monthly_revenue`, `marketing_spend`

This document catalogs every measure in the model, grouped by measure table with its DAX expression, display format, business description, and dependencies.

---

## Table of Contents

1. [_Measures_Executive](#_measures_executive) — 15 measures
2. [_Measures_Revenue](#_measures_revenue) — 14 measures 
3. [_Measures_Customers](#_measures_customers) — 10 measures
4. [_Measures_Subsciption](#_measures_subsciption) — 6 measures
5. [_Measures_Marketing](#_measures_marketing) — 9 measures

---

## _Measures_Executive

### `Total MRR`

```dax
CALCULATE(SUM(subscriptions[mrr]), subscriptions[churned] = 0)
```

**Format:** `$#,0.00` · **Description:** Sum of MRR across all currently-active (non-churned) subscription rows.
**Depends on:** none



### `Active Customers`

```dax
DISTINCTCOUNT(subscriptions[customer_id])
```

**Format:** `0` · **Description:** Count of distinct customers with any subscription row. ⚠️ Not date-aware.
**Depends on:** none



### `Churn Events`

```dax
CALCULATE(
    COUNTROWS(subscription_events),
    subscription_events[event_type] = "churn"
)
```

**Format:** `0` · **Description:** Count of churn-type rows in the events log, filtered by whatever date context is active (this table *is* related to `Dim_Date`).
**Depends on:** none



### `Total Events`

```dax
COUNTROWS(subscription_events)
```

**Format:** `0` · **Description:** Total count of all subscription lifecycle events (new, expansion, contraction, churn) in context.
**Depends on:** none



### `Churn Rate`

```dax
DIVIDE(
    [Churn Events],
    [Total Events],
    0
)
```

**Format:** `0.00%` · **Description:** Share of all subscription events that were churn events.
**Depends on:** `Churn Events`, `Total Events`



### `Avg Customer LTV`

```dax
AVERAGE(customers[lifetime_value])
```

**Format:** `$#,0.00` · **Description:** Simple average of a static `lifetime_value` column on the customer dimension.
**Depends on:** none



### `Delta MRR`

```dax
SUM(subscription_events[delta_mrr])
```

**Format:** none set · **Description:** Net sum of all MRR deltas (positive and negative) recorded in the events log for the current context.
**Depends on:** none



### `Marketing Spend`

```dax
SUM(marketing_spend[spend])
```

**Format:** none set · **Description:** Total marketing spend in context (correctly date-aware via `Dim_Date`).
**Depends on:** none



### `CAC`

```dax
DIVIDE(
    [Marketing Spend],
    [New Customers],
    0
)
```

**Format:** `$#,0` · **Description:** Customer Acquisition Cost — marketing spend divided by new customers acquired in the period.
**Depends on:** `Marketing Spend`, `New Customers`



### `Funnel Stages`

```dax
DATATABLE(
    "Stage", STRING,
    {
        {"New Customers"},
        {"Expansion"},
        {"Renewals"},
        {"Contraction"},
        {"Churned"}
    }
)
```

**Description:** Static calculated table used to drive a funnel-chart visual's category axis — not a scalar measure in the usual sense.
**Depends on:** none



### `New MRR`

```dax
CALCULATE(
    SUM(subscription_events[new_mrr]),
    subscription_events[event_type] = "new"
)
```

**Description:** MRR added by brand-new subscriptions in the period.
**Depends on:** none



### `Expansion MRR`

```dax
CALCULATE(
    SUM(subscription_events[delta_mrr]),
    subscription_events[event_type]="Expansion"
)
```

**Format:** `$#,0.0` · **Description:** MRR gained from existing customers upgrading/expanding.
**Depends on:** none



### `Contraction MRR`

```dax
CALCULATE(
    ABS(SUM(subscription_events[delta_mrr])),
    subscription_events[event_type] = "contraction"
)
```

**Description:** MRR lost from existing customers downgrading (absolute value, i.e. a positive "loss" figure).
**Depends on:** none



### `Churned MRR`

```dax
CALCULATE(
    ABS(SUM(subscription_events[delta_mrr])),
    subscription_events[event_type] = "churn"
)
```

**Format:** `$#,0.0` · **Description:** MRR lost from cancellations (absolute value).
**Depends on:** none



### `Net MRR`

```dax
[New MRR]
+ [Expansion MRR]
- [Contraction MRR]
- [Churned MRR]
```

**Description:** MRR bridge/waterfall total — net change in MRR for the period from all movement types.
**Depends on:** `New MRR`, `Expansion MRR`, `Contraction MRR`, `Churned MRR`

---

## _Measures_Revenue



### `ARR`

```dax
[Total MRR] * 12
```

**Format:** `$#,0.0` · **Description:** Annual Recurring Revenue, annualized from `Total MRR`.
**Depends on:** `Total MRR`



### `Previous Month MRR`

```dax
CALCULATE(
    [Total MRR],
    DATEADD(Dim_Date[Date],-1,MONTH)
)
```

**Description:** Intended to be last month's MRR.
**Depends on:** `Total MRR`



### `MRR Growth Rate`

```dax
DIVIDE(
    [Total MRR] - [Previous Month MRR],
    [Previous Month MRR],
    0
)
```

**Format:** `0.0%` · **Description:** MoM MRR growth %.
**Depends on:** `Total MRR`, `Previous Month MRR`



### `Previous Year MRR`

```dax
CALCULATE(
    [Total MRR],
    DATEADD(Dim_Date[Date], -1, YEAR)
)
```

**Description:** Total MRR shifted back 12 months, used as the base for YoY comparisons.
**Depends on:** `Total MRR`



### `MRR YoY Growth %`

```dax
DIVIDE(
    [Total MRR] - [Previous Year MRR],
    [Previous Year MRR],
    0
)
```

**Format:** `0.0%` · **Description:** Year-over-year MRR growth %.
**Depends on:** `Total MRR`, `Previous Year MRR`



### `ARPU`

```dax
DIVIDE(
    [Total MRR],
    [Active Customers],
    0
)
```

**Format:** `$#,0` · **Description:** Average Revenue Per User — Total MRR divided by active customer count.
**Depends on:** `Total MRR`, `Active Customers`



### `GRR`

```dax
DIVIDE(
    [Previous Month MRR]
        - [Contraction MRR]
        - [Churned MRR],
    [Previous Month MRR],
    0
)
```

**Format:** `0.0%` · **Description:** Gross Revenue Retention — prior-period MRR net of contraction and churn only (excludes expansion), as a % of starting MRR.
**Depends on:** `Previous Month MRR`, `Contraction MRR`, `Churned MRR`



### `Latest MRR`

```dax
VAR LatestMonth =
    MAX(Dim_Date[Date])
RETURN
CALCULATE(
    SUM(monthly_revenue[mrr]),
    Dim_Date[Date] = LatestMonth
)
```

**Description:** MRR for the single most recent month in the current filter context, read directly from `monthly_revenue` rather than the `subscriptions` table.
**Depends on:** none



### `Historical MRR`

```dax
SUM(monthly_revenue[mrr])
```

**Description:** Total MRR summed directly from the `monthly_revenue` fact table (as opposed to `Total MRR`, which sums from `subscriptions`). Used for long-run trend visuals.
**Depends on:** none



### `Historical MRR PY`

```dax
CALCULATE(
    [Historical MRR],
    SAMEPERIODLASTYEAR(Dim_Date[Date])
)
```

**Description:** `Historical MRR` shifted back one year via `SAMEPERIODLASTYEAR`.
**Depends on:** `Historical MRR`



### `Historical MRR YoY %`

```dax
DIVIDE(
    [Historical MRR] - [Historical MRR PY],
    [Historical MRR PY]
)
```

**Format:** `0.0%` · **Description:** YoY growth % on the `monthly_revenue`-sourced trend line.
**Depends on:** `Historical MRR`, `Historical MRR PY`



### `Historical ARR`

```dax
[Historical MRR] * 12
```

**Format:** `$#,0.0` · **Description:** Annualized version of `Historical MRR`.
**Depends on:** `Historical MRR`


---

## _Measures_Customers

### `New Customers`

```dax
CALCULATE(
    DISTINCTCOUNT(subscription_events[customer_id]),
    subscription_events[event_type]="New"
)
```

**Format:** `0` · **Description:** Distinct count of customers with a "New" event in the current date context.
**Depends on:** none



### `ARPC`

```dax
DIVIDE(
    [Total MRR],
    [Active Customers]
)
```

**Format:** `$#,0` · **Description:** Average Revenue Per Customer. Same shape as `ARPU` but without the `0` default in `DIVIDE` — will return `BLANK()` instead of `0` on an empty filter context.
**Depends on:** `Total MRR`, `Active Customers`



### `Average Customer Tenure (Months)`

```dax
VAR MaxDate = MAX(Dim_Date[Date])
RETURN
ROUND(
    AVERAGEX(
        FILTER(
            subscriptions,
            subscriptions[churned] = 0
        ),
        DATEDIFF(
            subscriptions[start_date],
            MaxDate,
            MONTH
        )
    ),
    1
)
```

**Description:** Average tenure, in months, of currently-active (non-churned) subscriptions as of the latest date in context.
**Depends on:** none



### `Average Customer Tenure Display`

```dax
FORMAT([Average Customer Tenure (Months)], "0") & " Months"
```

**Description:** Text-formatted version of tenure for KPI card display (e.g. "14 Months").
**Depends on:** `Average Customer Tenure (Months)`



### `Customer Growth`

```dax
CALCULATE(
    [New Customers],
    FILTER(
        ALLSELECTED(Dim_Date[Date]),
        Dim_Date[Date] <= MAX(Dim_Date[Date])
    )
)
```

**Description:** Cumulative new-customer count up to the selected date, ignoring the current single-period date filter via `ALLSELECTED`.
**Depends on:** `New Customers`



### `Churned Customers`

```dax
CALCULATE(
    DISTINCTCOUNT(subscription_events[customer_id]),
    subscription_events[event_type]="Churn"
)
```

**Format:** `0` · **Description:** Distinct count of customers with a "Churn" event in the current date context.
**Depends on:** none



### `Beginning Customers`

```dax
CALCULATE(
    [Active Customers],
    DATEADD(Dim_Date[Date],-1,MONTH)
)
```

**Format:** `0` · **Description:** Active customer count as of one month before the selected date — used as the denominator for `Customer Churn %`.
**Depends on:** `Active Customers`



### `Customer Churn %`

```dax
DIVIDE(
    [Churned Customers],
    [Beginning Customers],
    0
)
```

**Format:** `0.0%` · **Description:** Churned customers as a % of beginning-of-period customers.
**Depends on:** `Churned Customers`, `Beginning Customers`



### `Average Customer Lifetime (Months)`

```dax
AVERAGE(subscriptions[tenure_months])
```

**Description:** Straight average of a precomputed `tenure_months` column — a simpler, ungoverned alternative to `Average Customer Tenure (Months)` above (that one filters to active subscriptions only and derives tenure live via `DATEDIFF`; this one averages a static column across all rows regardless of churn status). The two will not match exactly.
**Depends on:** none



### `Average Customer LTV`

```dax
[ARPU] *
[Average Customer Lifetime (Months)]
```

**Format:** `$#,0` · **Description:** *Modeled* LTV — ARPU × average tenure. This is a projection, and is a deliberately different concept from `Avg Customer LTV` in the Executive table, which is an *observed* LTV pulled straight from a precomputed `lifetime_value` column on the customer dimension. The two are not meant to reconcile: one is "what LTV should be given current unit economics," the other is "what LTV actually was, per customer record." Both are kept because they answer different questions, but the near-identical names invite confusion — renaming one (e.g. to `Modeled Customer LTV`) is recommended.
**Depends on:** `ARPU`, `Average Customer Lifetime (Months)`

---

## _Measures_Subsciption

### `Active Subscriptions`

```dax
VAR SelectedDate =
    MAX(Dim_Date[Date])
RETURN
CALCULATE(
    COUNTROWS(subscriptions),
    FILTER(
        subscriptions,
        subscriptions[start_date] <= SelectedDate &&
        (
            ISBLANK(subscriptions[end_date]) ||
            subscriptions[end_date] >= SelectedDate
        )
    )
)
```

**Format:** `0` · **Description:** Point-in-time count of subscriptions active as of the selected date — Calculates active subscriptions as of the selected date.
**Depends on:** none



### `New Subscriptions`

```dax
CALCULATE(
    COUNTROWS(subscriptions),
    TREATAS(
        VALUES(Dim_Date[Date]),
        subscriptions[start_date]
    )
)
```

**Format:** `0` · **Description:** Subscriptions started within the current date context, Counts subscriptions started in the selected date context.
**Depends on:** none



### `Churned Subscriptions`

```dax
CALCULATE(
    COUNTROWS(subscriptions),
    subscriptions[churned] = 1,
    TREATAS(
        VALUES(Dim_Date[Date]),
        subscriptions[end_date]
    )
)
```

**Format:** `0` · **Description:** Subscriptions that ended (churned) within the current date context.
**Depends on:** none



### `Renewal Rate`

```dax
CALCULATE(1 - [Customer Churn %])
```

**Format:** `0.00%` · **Description:** Inverse of churn %. Calculated as one minus Customer Churn %.
**Depends on:** `Customer Churn %`



### `Net Subscription Growth`

```dax
[New Subscriptions] - [Churned Subscriptions]
```

**Format:** `0` · **Description:** Net change in active subscription count for the period.
**Depends on:** `New Subscriptions`, `Churned Subscriptions`



### `Net Subscription Growth (Display)`

```dax
VAR Growth = [Net Subscription Growth]
RETURN
IF(
    Growth > 0,
    "+" & FORMAT(Growth, "#,##0"),
    FORMAT(Growth, "#,##0")
)
```

**Description:** Text-formatted net growth with an explicit "+" sign for positive values, for KPI card display.
**Depends on:** `Net Subscription Growth`

---

## _Measures_Marketing

### `LTV:CAC`

```dax
DIVIDE(
    [Average Customer LTV],
    [CAC]
)
```

**Description:** LTV-to-CAC ratio, a core SaaS unit-economics health metric (commonly benchmarked at 3:1+).
**Depends on:** `Average Customer LTV`, `CAC`



### `Revenue from New Customers`

```dax
CALCULATE(
    SUM(subscriptions[mrr]),
    TREATAS(
        VALUES(Dim_Date[Date]),
        subscriptions[start_date]
    )
)
```

**Description:** MRR attributable to subscriptions that started in the current date context — Calculates MRR from newly acquired subscriptions.
**Depends on:** none



### `Marketing ROI`

```dax
DIVIDE(
    [Revenue from New Customers] - [Marketing Spend],
    [Marketing Spend]
)
```

**Format:** `0%` · **Description:** Return on marketing spend, based on revenue generated from newly acquired customers.
**Depends on:** `Revenue from New Customers`, `Marketing Spend`



### `Average MRR per Customer`

```dax
AVERAGE(subscriptions[mrr])
```

**Description:** Row-level average MRR per subscription (not weighted by customer count directly — differs subtly from `ARPU`).
**Depends on:** none



### `CAC Payback Period (Months)`

```dax
DIVIDE(
    [CAC],
    [Average MRR per Customer],
    0
)
```

**Format:** `0.0` · **Description:** Months required to recover acquisition cost from average monthly revenue per customer.
**Depends on:** `CAC`, `Average MRR per Customer`



### `CAC Payback Period Display`

```dax
FORMAT([CAC Payback Period (Months)], "0.0") & " Months"
```

**Description:** Text-formatted version for card visuals (e.g. "6.2 Months").
**Depends on:** `CAC Payback Period (Months)`



### `LTV:CAC Ratio Display`

```dax
FORMAT([LTV:CAC], "0.0") & "x"
```

**Description:** Text-formatted ratio for card visuals (e.g. "3.5x").
**Depends on:** `LTV:CAC`



### `ROAS`

```dax
DIVIDE(
    [Revenue from New Customers],
    [Marketing Spend]
)
```

**Description:** Return On Ad Spend — revenue from new customers per dollar of marketing spend.
**Depends on:** `Revenue from New Customers`, `Marketing Spend`



### `Net Revenue Retention`

```dax
DIVIDE(
    [Previous Month MRR]
        + [Expansion MRR]
        - [Contraction MRR]
        - [Churned MRR],
    [Previous Month MRR]
)
```

**Format:** `0.0%` · **Description:** NRR — MRR retained plus expansion, minus contraction and churn, as % of starting MRR. Net Revenue Retention (NRR) based on MRR movement.
**Depends on:** `Previous Month MRR`, `Expansion MRR`, `Contraction MRR`, `Churned MRR`

---

## Measure Dependency Quick Reference

|Base measures with no dependencies|Fed into these composite measures|
|-|-|
|`Total MRR`|`ARR`, `Previous Month MRR`, `MRR Growth Rate`, `Previous Year MRR`, `MRR YoY Growth %`, `ARPU`, `ARPC`, `Test Previous Year Sales`|
|`Active Customers`|`ARPU`, `ARPC`, `Beginning Customers`|
|`Beginning Customers`, `Churned Customers`|`Customer Churn %`|
|`New MRR`, `Expansion MRR`, `Contraction MRR`, `Churned MRR`|`Net MRR`, `GRR`, `Net Revenue Retention`|
|`Historical MRR`|`Historical MRR PY`, `Historical MRR YoY %`, `Historical ARR`|
|`Marketing Spend`, `New Customers`|`CAC`|
|`Revenue from New Customers`|`Marketing ROI`, `ROAS`|
|`ARPU`, `Average Customer Lifetime (Months)`|`Average Customer LTV`|



