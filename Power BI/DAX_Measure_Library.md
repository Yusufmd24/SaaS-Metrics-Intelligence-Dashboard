# SaaS Metrics Intelligence Dashboard — Complete DAX Measure Library

**Model:** `SaaS\_Analytics\_Dashboard`
**Total measures:** 54, across 5 measure tables
**Source data:** `customers`, `subscriptions`, `subscription\_events`, `monthly\_revenue`, `marketing\_spend`

This document catalogs every measure in the model, grouped by measure table with its DAX expression, display format, business description, and dependencies.

\---

## Table of Contents

1. [\_Measures\_Executive](#_measures_executive) — 15 measures
2. [\_Measures\_Revenue](#_measures_revenue) — 14 measures
3. [\_Measures\_Customers](#_measures_customers) — 10 measures
4. [\_Measures\_Subsciption](#_measures_subsciption) — 6 measures
5. [\_Measures\_Marketing](#_measures_marketing) — 9 measures

\---

## \_Measures\_Executive

### `Total MRR`

```dax
CALCULATE(SUM(subscriptions\[mrr]), subscriptions\[churned] = 0)
```

**Format:** `$#,0.00` · **Description:** Sum of MRR across all currently-active (non-churned) subscription rows.
**Depends on:** none



### `Total Customers`

```dax
DISTINCTCOUNT(subscriptions\[customer\_id])
```

**Format:** `0` · **Description:** Count of distinct customers with any subscription row. ⚠️ Not date-aware.
**Depends on:** none



### `Churn Events`

```dax
CALCULATE(
    COUNTROWS(subscription\_events),
    subscription\_events\[event\_type] = "churn"
)
```

**Format:** `0` · **Description:** Count of churn-type rows in the events log, filtered by whatever date context is active (this table *is* related to `Dim\_Date`).
**Depends on:** none



### `Total Events`

```dax
COUNTROWS(subscription\_events)
```

**Format:** `0` · **Description:** Total count of all subscription lifecycle events (new, expansion, contraction, churn) in context.
**Depends on:** none



### `Churn Rate`

```dax
DIVIDE(
    \[Churn Events],
    \[Total Events],
    0
)
```

**Format:** `0.00%` · **Description:** Share of all subscription events that were churn events.
**Depends on:** `Churn Events`, `Total Events`



### `Avg Customer LTV`

```dax
AVERAGE(customers\[lifetime\_value])
```

**Format:** `$#,0.00` · **Description:** Simple average of a static `lifetime\_value` column on the customer dimension.
**Depends on:** none



### `Delta MRR`

```dax
SUM(subscription\_events\[delta\_mrr])
```

**Format:** none set · **Description:** Net sum of all MRR deltas (positive and negative) recorded in the events log for the current context.
**Depends on:** none



### `Marketing Spend`

```dax
SUM(marketing\_spend\[spend])
```

**Format:** none set · **Description:** Total marketing spend in context (correctly date-aware via `Dim\_Date`).
**Depends on:** none



### `CAC`

```dax
DIVIDE(
    \[Marketing Spend],
    \[New Customers],
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
    SUM(subscription\_events\[new\_mrr]),
    subscription\_events\[event\_type] = "new"
)
```

**Description:** MRR added by brand-new subscriptions in the period.
**Depends on:** none



### `Expansion MRR`

```dax
CALCULATE(
    SUM(subscription\_events\[delta\_mrr]),
    subscription\_events\[event\_type]="Expansion"
)
```

**Format:** `$#,0.0` · **Description:** MRR gained from existing customers upgrading/expanding.
**Depends on:** none



### `Contraction MRR`

```dax
CALCULATE(
    ABS(SUM(subscription\_events\[delta\_mrr])),
    subscription\_events\[event\_type] = "contraction"
)
```

**Description:** MRR lost from existing customers downgrading (absolute value, i.e. a positive "loss" figure).
**Depends on:** none



### `Churned MRR`

```dax
CALCULATE(
    ABS(SUM(subscription\_events\[delta\_mrr])),
    subscription\_events\[event\_type] = "churn"
)
```

**Format:** `$#,0.0` · **Description:** MRR lost from cancellations (absolute value).
**Depends on:** none



### `Net MRR`

```dax
\[New MRR]
+ \[Expansion MRR]
- \[Contraction MRR]
- \[Churned MRR]
```

**Description:** MRR bridge/waterfall total — net change in MRR for the period from all movement types.
**Depends on:** `New MRR`, `Expansion MRR`, `Contraction MRR`, `Churned MRR`

\---

## \_Measures\_Revenue



### `ARR`

```dax
\[Total MRR] \* 12
```

**Format:** `$#,0.0` · **Description:** Annual Recurring Revenue, annualized from `Total MRR`.
**Depends on:** `Total MRR`



### `Previous Month MRR`

```dax
CALCULATE(
    \[Total MRR],
    DATEADD(Dim\_Date\[Date],-1,MONTH)
)
```

**Description:** Intended to be last month's MRR.
**Depends on:** `Total MRR`



### `MRR Growth Rate`

```dax
DIVIDE(
    \[Total MRR] - \[Previous Month MRR],
    \[Previous Month MRR],
    0
)
```

**Format:** `0.0%` · **Description:** Intended MoM MRR growth %.
**Depends on:** `Total Customers`



### `Customer Churn %`

```dax
DIVIDE(
    \[Churned Customers],
    \[Beginning Customers],
    0
)
```

**Format:** `0.0%` · **Description:** Churned customers as a % of beginning-of-period customers. Inherits the broken `Beginning Customers`.
**Depends on:** `Churned Customers`, `Beginning Customers`



### `Average Customer Lifetime (Months)`

```dax
AVERAGE(subscriptions\[tenure\_months])
```

**Description:** Straight average of a precomputed `tenure\_months` column.
**Depends on:** none



### `Average Customer LTV`

```dax
\[ARPU] \*
\[Average Customer Lifetime (Months)]
```

**Format:** `$#,0` · **Description:** LTV estimated as ARPU × average tenure. See Known Issue #3 — separate concept/formula from `Avg Customer LTV` in the Executive table.
**Depends on:** `ARPU`, `Average Customer Lifetime (Months)`

\---

## \_Measures\_Subsciption

### `Active Subscriptions`

```dax
VAR SelectedDate =
    MAX(Dim\_Date\[Date])
RETURN
CALCULATE(
    COUNTROWS(subscriptions),
    FILTER(
        subscriptions,
        subscriptions\[start\_date] <= SelectedDate \&\&
        (
            ISBLANK(subscriptions\[end\_date]) ||
            subscriptions\[end\_date] >= SelectedDate
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
        VALUES(Dim\_Date\[Date]),
        subscriptions\[start\_date]
    )
)
```

**Format:** `0` · **Description:** Subscriptions started within the current date context, Counts subscriptions started in the selected date context.
**Depends on:** none



### `Churned Subscriptions`

```dax
CALCULATE(
    COUNTROWS(subscriptions),
    subscriptions\[churned] = 1,
    TREATAS(
        VALUES(Dim\_Date\[Date]),
        subscriptions\[end\_date]
    )
)
```

**Format:** `0` · **Description:** Subscriptions that ended (churned) within the current date context.
**Depends on:** none



### `Renewal Rate`

```dax
CALCULATE(1 - \[Customer Churn %])
```

**Format:** `0.00%` · **Description:** Inverse of churn %. Calculated as one minus Customer Churn %.
**Depends on:** `Customer Churn %`



### `Net Subscription Growth`

```dax
\[New Subscriptions] - \[Churned Subscriptions]
```

**Format:** `0` · **Description:** Net change in active subscription count for the period.
**Depends on:** `New Subscriptions`, `Churned Subscriptions`



### `Net Subscription Growth (Display)`

```dax
VAR Growth = \[Net Subscription Growth]
RETURN
IF(
    Growth > 0,
    "+" \& FORMAT(Growth, "#,##0"),
    FORMAT(Growth, "#,##0")
)
```

**Description:** Text-formatted net growth with an explicit "+" sign for positive values, for KPI card display.
**Depends on:** `Net Subscription Growth`

\---

## \_Measures\_Marketing

### `LTV:CAC`

```dax
DIVIDE(
    \[Average Customer LTV],
    \[CAC]
)
```

**Description:** LTV-to-CAC ratio, a core SaaS unit-economics health metric (commonly benchmarked at 3:1+).
**Depends on:** `Average Customer LTV`, `CAC`



### `Revenue from New Customers`

```dax
CALCULATE(
    SUM(subscriptions\[mrr]),
    TREATAS(
        VALUES(Dim\_Date\[Date]),
        subscriptions\[start\_date]
    )
)
```

**Description:** MRR attributable to subscriptions that started in the current date context — Calculates MRR from newly acquired subscriptions.
**Depends on:** none



### `Marketing ROI`

```dax
DIVIDE(
    \[Revenue from New Customers] - \[Marketing Spend],
    \[Marketing Spend]
)
```

**Format:** `0%` · **Description:** Return on marketing spend, based on revenue generated from newly acquired customers.
**Depends on:** `Revenue from New Customers`, `Marketing Spend`



### `Average MRR per Customer`

```dax
AVERAGE(subscriptions\[mrr])
```

**Description:** Row-level average MRR per subscription (not weighted by customer count directly — differs subtly from `ARPU`).
**Depends on:** none



### `CAC Payback Period (Months)`

```dax
DIVIDE(
    \[CAC],
    \[Average MRR per Customer],
    0
)
```

**Format:** `0.0` · **Description:** Months required to recover acquisition cost from average monthly revenue per customer.
**Depends on:** `CAC`, `Average MRR per Customer`



### `CAC Payback Period Display`

```dax
FORMAT(\[CAC Payback Period (Months)], "0.0") \& " Months"
```

**Description:** Text-formatted version for card visuals (e.g. "6.2 Months").
**Depends on:** `CAC Payback Period (Months)`



### `LTV:CAC Ratio Display`

```dax
FORMAT(\[LTV:CAC], "0.0") \& "x"
```

**Description:** Text-formatted ratio for card visuals (e.g. "3.5x").
**Depends on:** `LTV:CAC`



### `ROAS`

```dax
DIVIDE(
    \[Revenue from New Customers],
    \[Marketing Spend]
)
```

**Description:** Return On Ad Spend — revenue from new customers per dollar of marketing spend.
**Depends on:** `Revenue from New Customers`, `Marketing Spend`



### `Net Revenue Retention`

```dax
DIVIDE(
    \[Previous Month MRR]
        + \[Expansion MRR]
        - \[Contraction MRR]
        - \[Churned MRR],
    \[Previous Month MRR]
)
```

**Format:** `0.0%` · **Description:** NRR — MRR retained plus expansion, minus contraction and churn, as % of starting MRR. Net Revenue Retention (NRR) based on MRR movement.
**Depends on:** `Previous Month MRR`, `Expansion MRR`, `Contraction MRR`, `Churned MRR`

\---

## Measure Dependency Quick Reference

|Base measures with no dependencies|Fed into these composite measures|
|-|-|
|`Total MRR`|`ARR`, `Previous Month MRR`, `MRR Growth Rate`, `Previous Year MRR`, `MRR YoY Growth %`, `ARPU`, `ARPC`, `Test Previous Year Sales`|
|`Total Customers`|`ARPU`, `ARPC`, `Beginning Customers`, `Customer Churn %`|
|`New MRR`, `Expansion MRR`, `Contraction MRR`, `Churned MRR`|`Net MRR`, `GRR`, `Net Revenue Retention`|
|`Historical MRR`|`Historical MRR PY`, `Historical MRR YoY %`, `Historical ARR`|
|`Marketing Spend`, `New Customers`|`CAC`|
|`Revenue from New Customers`|`Marketing ROI`, `ROAS`|



