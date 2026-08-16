/* ================================================================
   SQL-S8 STUDY GUIDE — PART 7: DISTINCT WITH AGGREGATES + NULL HANDLING
   Prerequisite: run 00_Setup.sql first.
   ================================================================ */

USE ContosoRetailDW;
GO


/* ================================================================
   ## 7.1 COUNT(DISTINCT column)
   ================================================================ */

-- Demo: how many unique customers bought something online?
SELECT COUNT(DISTINCT CustomerKey) AS UniqueCustomers
FROM dbo.FactOnlineSales;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) COUNT(DISTINCT ...) ignores NULLs too — a NULL value never
   --     counts as "a unique value"
   -- SELECT COUNT(DISTINCT PromotionKey) AS UniquePromotions FROM dbo.FactOnlineSales;

   -- (b) You can COUNT(DISTINCT ...) inside a GROUP BY, e.g. unique
   --     customers PER store
   -- SELECT StoreKey, COUNT(DISTINCT CustomerKey) AS UniqueCustomers
   -- FROM dbo.FactOnlineSales
   -- GROUP BY StoreKey;

   -- (c) SQL Server does NOT allow COUNT(DISTINCT col1, col2) with
   --     two columns directly — for a distinct-combination count,
   --     wrap it in a subquery instead:
   -- SELECT COUNT(*) FROM (SELECT DISTINCT StoreKey, CurrencyKey FROM dbo.FactOnlineSales) AS x;
   ---------------------------------------------------------------- */


/* ================================================================
   ## 7.2 NULLs in aggregation
   ================================================================
   Aggregate functions (SUM, AVG, MIN, MAX, COUNT(column)) IGNORE NULLs.
   COUNT(*) counts rows regardless of NULLs; COUNT(column) does not
   count rows where that column is NULL.
   ================================================================ */

-- Demo: insert one row with a NULL DiscountAmount to see the effect.
INSERT INTO dbo.FactOnlineSales_Practice
    (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
     CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
     SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
     DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
VALUES
    (999003, 20090801, 199, 501, 1,
     100, 20001, 'SO999003', 1,
     1, 50.00, 0, 0,
     0, NULL, 30.00, 30.00, 50.00);
GO

SELECT
    COUNT(*)                  AS AllRows,
    COUNT(DiscountAmount)     AS RowsWithNonNullDiscount,
    SUM(DiscountAmount)       AS TotalDiscount_NullsIgnored,
    AVG(ISNULL(DiscountAmount, 0)) AS AvgDiscount_NullsAsZero
FROM dbo.FactOnlineSales_Practice;
GO

-- Clean up the test row:
DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999003;
GO

/* ----------------------------------------------------------------
   Variations — functions for handling NULLs:

   -- (a) ISNULL(expr, replacement) — SQL Server-specific, exactly
   --     TWO arguments, return type matches the FIRST argument
   -- SELECT ISNULL(DiscountAmount, 0) AS SafeDiscount FROM dbo.FactOnlineSales;

   -- (b) COALESCE(expr1, expr2, ..., exprN) — ANSI-standard, works
   --     across databases (PostgreSQL, MySQL, Oracle...), accepts
   --     ANY number of arguments, returns the FIRST non-NULL one
   -- SELECT COALESCE(DiscountAmount, PromotionKey, 0) AS FirstAvailable
   -- FROM dbo.FactOnlineSales;
   -- -- Prefer COALESCE for portability; ISNULL is sometimes a hair
   -- -- faster in SQL Server, but ties you to this one product.

   -- (c) NULLIF(expr1, expr2) — returns NULL if the two are equal,
   --     otherwise returns expr1. Handy for avoiding divide-by-zero:
   -- SELECT SalesAmount / NULLIF(SalesQuantity, 0) AS PricePerUnit
   -- FROM dbo.FactOnlineSales;

   -- (d) IS NULL / IS NOT NULL are the ONLY correct ways to test
   --     for NULL in a WHERE/HAVING clause (see Part 4.1) —
   --     "= NULL" and "<> NULL" always evaluate to unknown, never true.

   -- (e) Three-valued logic: every WHERE/HAVING condition evaluates
   --     to TRUE, FALSE, or UNKNOWN. Only rows where the condition
   --     is TRUE are returned — UNKNOWN rows (usually caused by a
   --     NULL somewhere in the comparison) are silently excluded,
   --     which is exactly why the NOT IN pitfall in Part 4.3 happens.
   ---------------------------------------------------------------- */


/* ================================================================
   ## 7.3 Exercises — DISTINCT + NULLs
   ================================================================ */

-- Exercise 7.1: How many distinct ProductKeys appear in FactOnlineSales?
-- Write your query below:


-- Solution:
-- SELECT COUNT(DISTINCT ProductKey) AS UniqueProducts FROM dbo.FactOnlineSales;

-- Exercise 7.2: Insert a practice row (any key, e.g. 999004) with SalesAmount = 75
-- and ReturnAmount = NULL. Then write a query showing COUNT(*) vs
-- COUNT(ReturnAmount) on dbo.FactOnlineSales_Practice to prove NULLs aren't counted.
-- Clean the row up afterwards.
-- Write your query below:


-- Solution:
-- INSERT INTO dbo.FactOnlineSales_Practice
--     (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
--      CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
--      SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
--      DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
-- VALUES
--     (999004, 20090901, 199, 502, 1, 100, 20002, 'SO999004', 1,
--      1, 75.00, 0, NULL, 0, 0, 40.00, 40.00, 75.00);
--
-- SELECT COUNT(*) AS AllRows, COUNT(ReturnAmount) AS NonNullReturnAmount
-- FROM dbo.FactOnlineSales_Practice;
--
-- DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999004;

-- Exercise 7.3: Using COALESCE, show SalesAmount and a "SafeDiscount" column
-- that replaces NULL DiscountAmount with 0 for the first 20 rows of FactOnlineSales.
-- Write your query below:


-- Solution:
-- SELECT TOP 20 SalesAmount, COALESCE(DiscountAmount, 0) AS SafeDiscount
-- FROM dbo.FactOnlineSales;

-- Exercise 7.4: Using NULLIF, compute SalesAmount / SalesQuantity for the first
-- 20 rows without risking a divide-by-zero error.
-- Write your query below:


-- Solution:
-- SELECT TOP 20 SalesAmount, SalesQuantity,
--        SalesAmount / NULLIF(SalesQuantity, 0) AS PricePerUnit
-- FROM dbo.FactOnlineSales;


/* ================================================================
   Continue to 08_Final_Review.sql next.
   ================================================================ */
