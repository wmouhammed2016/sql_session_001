/* ================================================================
   SQL-S8 STUDY GUIDE — PART 5: AGGREGATE FUNCTIONS
   ================================================================
   Statements covered: COUNT, SUM, AVG, MIN, MAX, and a look at
   less common but useful aggregates.
   ================================================================ */

USE ContosoRetailDW;
GO


/* ================================================================
   ## 5.1 The core five
   ================================================================ */

-- Demo: overall online sales summary
SELECT
    COUNT(*)               AS TotalLines,
    SUM(SalesAmount)       AS TotalRevenue,
    AVG(SalesAmount)       AS AvgLineAmount,
    MIN(SalesAmount)       AS SmallestSale,
    MAX(SalesAmount)       AS LargestSale
FROM dbo.FactOnlineSales;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) COUNT(*) vs COUNT(column) vs COUNT(DISTINCT column)
   --     COUNT(*)              -> counts every row, NULLs included
   --     COUNT(SomeColumn)     -> counts only rows where that column is NOT NULL
   --     COUNT(DISTINCT col)   -> counts unique non-NULL values (see Part 7)
   -- SELECT COUNT(*) AS AllRows, COUNT(PromotionKey) AS RowsWithPromotion
   -- FROM dbo.FactOnlineSales;

   -- (b) SUM/AVG with DISTINCT — aggregate only the unique values
   -- SELECT SUM(DISTINCT UnitPrice) AS SumOfDistinctPrices FROM dbo.FactOnlineSales;

   -- (c) MIN/MAX work on dates and text too, not just numbers
   -- SELECT MIN(SalesOrderNumber) AS FirstOrderAlphabetically,
   --        MAX(SalesOrderNumber) AS LastOrderAlphabetically
   -- FROM dbo.FactOnlineSales;

   -- (d) Statistical aggregates — standard deviation and variance
   -- SELECT STDEV(SalesAmount) AS StdDevSales, VAR(SalesAmount) AS VarianceSales
   -- FROM dbo.FactOnlineSales;
   -- -- STDEV/VAR use the SAMPLE formula; STDEVP/VARP use the POPULATION formula.

   -- (e) STRING_AGG (SQL Server 2017+) — concatenate text values
   --     from multiple rows into one string, with a separator
   -- SELECT STRING_AGG(SalesOrderNumber, ', ') AS AllOrders
   -- FROM dbo.FactOnlineSales WHERE StoreKey = 199;

   -- Aggregate functions IGNORE NULLs (except COUNT(*)) — the full
   -- explanation and a hands-on demo is in Part 7.

   -- Preview (not covered hands-on this session): WINDOW functions
   -- let you compute an aggregate WITHOUT collapsing rows, e.g.
   -- SELECT OnlineSalesKey, SalesAmount,
   --        SUM(SalesAmount) OVER (PARTITION BY StoreKey) AS StoreTotal
   -- FROM dbo.FactOnlineSales;
   -- -- Every row keeps its detail AND sees its store's total alongside it.
   ---------------------------------------------------------------- */


/* ================================================================
   ## 5.2 Exercises — Aggregate functions
   ================================================================ */

-- Exercise 5.1: How many sales lines resulted in a return (ReturnQuantity > 0)?
-- Write your query below:


-- Solution:
-- SELECT COUNT(*) AS LinesWithReturns
-- FROM dbo.FactOnlineSales
-- WHERE ReturnQuantity > 0;

-- Exercise 5.2: What is the total SalesQuantity sold across all lines?
-- Write your query below:


-- Solution:
-- SELECT SUM(SalesQuantity) AS TotalUnitsSold FROM dbo.FactOnlineSales;

-- Exercise 5.3: What is the average UnitPrice, and what are the min/max UnitPrice?
-- Write your query below:


-- Solution:
-- SELECT AVG(UnitPrice) AS AvgUnitPrice, MIN(UnitPrice) AS MinUnitPrice,
--        MAX(UnitPrice) AS MaxUnitPrice
-- FROM dbo.FactOnlineSales;

-- Exercise 5.4: How many rows actually have a non-NULL PromotionKey, versus
-- the total row count? (Use two different COUNT() variations in one query.)
-- Write your query below:


-- Solution:
-- SELECT COUNT(*) AS AllRows, COUNT(PromotionKey) AS RowsWithPromotion
-- FROM dbo.FactOnlineSales;


/* ================================================================
   Continue to 06_GROUP_BY_HAVING.sql next.
   ================================================================ */
