/*=========================================================
    SAAS ANALYTICS - BUSINESS ANALYSIS QUERIES
=========================================================*/

-- =====================================================
-- 1. TOTAL MRR
-- =====================================================

SELECT
    SUM(MRR) AS Total_MRR
FROM Fact_Revenue;


-- =====================================================
-- 2. MONTHLY REVENUE TREND
-- =====================================================

SELECT
    d.Year_Number,
    d.Month_Number,
    SUM(fr.MRR) AS Monthly_Revenue
FROM Fact_Revenue fr
JOIN Dim_Date d
    ON fr.Date_ID = d.Date_ID
GROUP BY
    d.Year_Number,
    d.Month_Number
ORDER BY
    d.Year_Number,
    d.Month_Number;


-- =====================================================
-- 3. REVENUE BY INDUSTRY
-- =====================================================

SELECT
    dc.Industry,
    SUM(fr.MRR) AS Total_Revenue
FROM Fact_Revenue fr
JOIN Dim_Customer dc
    ON fr.Customer_ID = dc.Customer_ID
GROUP BY dc.Industry
ORDER BY Total_Revenue DESC;


-- =====================================================
-- 4. REVENUE BY ACQUISITION CHANNEL
-- =====================================================

SELECT
    dc.Acquisition_Channel,
    SUM(fr.MRR) AS Total_Revenue
FROM Fact_Revenue fr
JOIN Dim_Customer dc
    ON fr.Customer_ID = dc.Customer_ID
GROUP BY dc.Acquisition_Channel
ORDER BY Total_Revenue DESC;


-- =====================================================
-- 5. REVENUE BY COUNTRY
-- =====================================================

SELECT
    dc.Country,
    SUM(fr.MRR) AS Total_Revenue
FROM Fact_Revenue fr
JOIN Dim_Customer dc
    ON fr.Customer_ID = dc.Customer_ID
GROUP BY dc.Country
ORDER BY Total_Revenue DESC;


-- =====================================================
-- 6. REVENUE BY COMPANY SIZE
-- =====================================================

SELECT
    dc.Employee_Size,
    SUM(fr.MRR) AS Total_Revenue
FROM Fact_Revenue fr
JOIN Dim_Customer dc
    ON fr.Customer_ID = dc.Customer_ID
GROUP BY dc.Employee_Size
ORDER BY Total_Revenue DESC;


-- =====================================================
-- 7. TOP 10 CUSTOMERS BY LIFETIME VALUE
-- =====================================================

SELECT TOP 10
    Customer_ID,
    Company_Name,
    Lifetime_Value
FROM Dim_Customer
ORDER BY Lifetime_Value DESC;


-- =====================================================
-- 8. EVENT DISTRIBUTION
-- =====================================================

SELECT
    Event_Type,
    COUNT(*) AS Event_Count
FROM Fact_Subscription_Events
GROUP BY Event_Type
ORDER BY Event_Count DESC;


-- =====================================================
-- 9. CHURN EVENTS
-- =====================================================

SELECT
    COUNT(*) AS Churn_Events
FROM Fact_Subscription_Events
WHERE Event_Type = 'Churn';


-- =====================================================
-- 10. EXPANSION MRR
-- =====================================================

SELECT
    SUM(Delta_MRR) AS Expansion_MRR
FROM Fact_Subscription_Events
WHERE Event_Type = 'Expansion';


-- =====================================================
-- 11. CONTRACTION MRR
-- =====================================================

SELECT
    SUM(ABS(Delta_MRR)) AS Contraction_MRR
FROM Fact_Subscription_Events
WHERE Event_Type = 'Contraction';


-- =====================================================
-- 12. NET REVENUE CHANGE
-- =====================================================

SELECT
    SUM(Delta_MRR) AS Net_Revenue_Change
FROM Fact_Subscription_Events;


-- =====================================================
-- 13. MARKETING SPEND BY CHANNEL
-- =====================================================

SELECT
    Channel,
    SUM(Spend) AS Total_Spend
FROM Fact_Marketing_Spend
GROUP BY Channel
ORDER BY Total_Spend DESC;


-- =====================================================
-- 14. MONTHLY MARKETING SPEND TREND
-- =====================================================

SELECT
    d.Year_Number,
    d.Month_Number,
    SUM(ms.Spend) AS Monthly_Spend
FROM Fact_Marketing_Spend ms
JOIN Dim_Date d
    ON ms.Date_ID = d.Date_ID
GROUP BY
    d.Year_Number,
    d.Month_Number
ORDER BY
    d.Year_Number,
    d.Month_Number;


-- =====================================================
-- 15. REVENUE VS MARKETING SPEND
-- =====================================================

WITH Revenue_CTE AS
(
    SELECT
        Date_ID,
        SUM(MRR) AS Revenue
    FROM Fact_Revenue
    GROUP BY Date_ID
),

Spend_CTE AS
(
    SELECT
        Date_ID,
        SUM(Spend) AS Marketing_Spend
    FROM Fact_Marketing_Spend
    GROUP BY Date_ID
)

SELECT
    d.Year_Number,
    d.Month_Number,
    r.Revenue,
    s.Marketing_Spend
FROM Dim_Date d
LEFT JOIN Revenue_CTE r
    ON d.Date_ID = r.Date_ID
LEFT JOIN Spend_CTE s
    ON d.Date_ID = s.Date_ID
ORDER BY
    d.Year_Number,
    d.Month_Number;