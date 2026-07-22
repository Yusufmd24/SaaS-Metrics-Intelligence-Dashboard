
/*=========================================================
    SAAS ANALYTICS DATA WAREHOUSE
=========================================================*/


-- =============================================
-- DIM_CUSTOMER
-- =============================================

CREATE TABLE Dim_Customer
(
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Company_Name VARCHAR(100),
    Industry VARCHAR(50),
    Employee_Size VARCHAR(20),
    Signup_Date DATE,
    Sales_Rep VARCHAR(100),
    Acquisition_Channel VARCHAR(50),
    Country VARCHAR(50),
    Lifetime_Value DECIMAL(18,2)
);

-- =============================================
-- DIM_DATE
-- =============================================

CREATE TABLE Dim_Date
(
    Date_ID INT PRIMARY KEY,
    Full_Date DATE,
    Year_Number INT,
    Quarter_Number INT,
    Month_Number INT,
    Month_Name VARCHAR(20)
);

-- =============================================
-- FACT_REVENUE
-- =============================================

CREATE TABLE Fact_Revenue
(
    Revenue_ID INT IDENTITY(1,1) PRIMARY KEY,

    Customer_ID VARCHAR(20) NOT NULL,
    Date_ID INT NOT NULL,

    MRR DECIMAL(18,2),
    Event_Type VARCHAR(30),

    CONSTRAINT FK_Revenue_Customer
        FOREIGN KEY (Customer_ID)
        REFERENCES Dim_Customer(Customer_ID),

    CONSTRAINT FK_Revenue_Date
        FOREIGN KEY (Date_ID)
        REFERENCES Dim_Date(Date_ID)
);

-- =============================================
-- FACT_SUBSCRIPTION_EVENTS
-- =============================================

CREATE TABLE Fact_Subscription_Events
(
    Event_Key INT IDENTITY(1,1) PRIMARY KEY,

    Event_ID VARCHAR(30),
    Customer_ID VARCHAR(20) NOT NULL,
    Date_ID INT NOT NULL,

    Event_Type VARCHAR(30),
    Old_MRR DECIMAL(18,2),
    New_MRR DECIMAL(18,2),
    Delta_MRR DECIMAL(18,2),

    CONSTRAINT FK_Event_Customer
        FOREIGN KEY (Customer_ID)
        REFERENCES Dim_Customer(Customer_ID),

    CONSTRAINT FK_Event_Date
        FOREIGN KEY (Date_ID)
        REFERENCES Dim_Date(Date_ID)
);

-- =============================================
-- FACT_MARKETING_SPEND
-- =============================================

CREATE TABLE Fact_Marketing_Spend
(
    Spend_ID INT IDENTITY(1,1) PRIMARY KEY,

    Date_ID INT NOT NULL,

    Channel VARCHAR(50),
    Spend DECIMAL(18,2),

    CONSTRAINT FK_Spend_Date
        FOREIGN KEY (Date_ID)
        REFERENCES Dim_Date(Date_ID)
);