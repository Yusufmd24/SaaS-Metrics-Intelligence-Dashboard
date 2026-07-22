/*=========================================================
    LOAD DIM_CUSTOMER
=========================================================*/

INSERT INTO Dim_Customer
(
    Customer_ID,
    Company_Name,
    Industry,
    Employee_Size,
    Signup_Date,
    Sales_Rep,
    Acquisition_Channel,
    Country,
    Lifetime_Value
)
SELECT
    customer_id,
    company_name,
    industry,
    employee_size,
    signup_date,
    sales_rep,
    acquisition_channel,
    country,
    lifetime_value
FROM customers;


/*=========================================================
    LOAD DIM_DATE
=========================================================*/

INSERT INTO Dim_Date
(
    Date_ID,
    Full_Date,
    Year_Number,
    Quarter_Number,
    Month_Number,
    Month_Name
)
SELECT DISTINCT
    year * 100 + month_number AS Date_ID,

    DATEFROMPARTS(year, month_number, 1) AS Full_Date,

    year,
    CAST(quarter AS INT),
    month_number,
    month_name

FROM
(
    SELECT year, quarter, month_number, month_name
    FROM monthly_revenue

    UNION

    SELECT
        year,
        quarter,
        month_number,
        month_name
    FROM marketing_spend
) d;


/*=========================================================
    LOAD FACT_REVENUE
=========================================================*/

INSERT INTO Fact_Revenue
(
    Customer_ID,
    Date_ID,
    MRR,
    Event_Type
)
SELECT
    customer_id,

    year * 100 + month_number AS Date_ID,

    mrr,
    event_type

FROM monthly_revenue;


/*=========================================================
    LOAD FACT_SUBSCRIPTION_EVENTS
=========================================================*/

INSERT INTO Fact_Subscription_Events
(
    Event_ID,
    Customer_ID,
    Date_ID,
    Event_Type,
    Old_MRR,
    New_MRR,
    Delta_MRR
)
SELECT
    event_id,
    customer_id,

    YEAR(event_date) * 100 +
    MONTH(event_date),

    event_type,
    old_mrr,
    new_mrr,
    delta_mrr

FROM subscription_events;


/*=========================================================
    LOAD FACT_MARKETING_SPEND
=========================================================*/

INSERT INTO Fact_Marketing_Spend
(
    Date_ID,
    Channel,
    Spend
)
SELECT
    year * 100 + month_number,

    channel,
    spend

FROM marketing_spend;



