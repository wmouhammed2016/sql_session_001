/* ================================================================
   SQL-S8 STUDY GUIDE — PART 6: GROUP BY and HAVING
   ================================================================ */

USE ContosoRetailDW;
GO


/* ================================================================
   ## 6.1 GROUP BY — aggregate per group
   ================================================================ */

-- Demo: revenue and line count per store
SELECT
    StoreKey,
    COUNT(*)         AS LineCount,
    SUM(SalesAmount) AS Revenue
FROM dbo.FactOnlineSales
GROUP BY StoreKey
ORDER BY Revenue DESC;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) GROUP BY multiple columns — one group per unique
   --     COMBINATION of values
   -- SELECT StoreKey, CurrencyKey, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY StoreKey, CurrencyKey;

   -- (b) GROUP BY an expression, not just a raw column — e.g. group
   --     by year, extracted from the DateKey surrogate key
   -- SELECT DateKey / 10000 AS SalesYear, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY DateKey / 10000
   -- ORDER BY SalesYear;

   -- (c) ROLLUP — adds subtotal + grand-total rows automatically
   -- SELECT StoreKey, CurrencyKey, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY ROLLUP (StoreKey, CurrencyKey);
   -- -- Produces: one row per (StoreKey, CurrencyKey), plus a subtotal
   -- -- row per StoreKey (CurrencyKey = NULL), plus one grand-total
   -- -- row (both NULL).

   -- (d) CUBE — like ROLLUP, but adds subtotals for EVERY combination
   --     of grouping columns, not just a hierarchy
   -- SELECT StoreKey, CurrencyKey, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY CUBE (StoreKey, CurrencyKey);

   -- (e) GROUPING SETS — hand-pick exactly which grouping
   --     combinations you want, in one query
   -- SELECT StoreKey, CurrencyKey, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY GROUPING SETS ((StoreKey), (CurrencyKey), ());
   ---------------------------------------------------------------- */


/* ================================================================
   ## 6.2 HAVING — filter the GROUPS (not the raw rows)
   ================================================================
   WHERE filters rows BEFORE grouping happens; HAVING filters the
   already-computed groups AFTER grouping/aggregating. That's why
   HAVING can reference aggregate functions like SUM(...) and WHERE
   cannot.
   ================================================================ */

-- Demo: only stores with more than $10,000 in revenue
SELECT
    StoreKey,
    SUM(SalesAmount) AS Revenue
FROM dbo.FactOnlineSales
GROUP BY StoreKey
HAVING SUM(SalesAmount) > 10000
ORDER BY Revenue DESC;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) Combine WHERE + GROUP BY + HAVING — WHERE trims the raw
   --     rows first (cheaper), THEN the survivors get grouped, THEN
   --     HAVING trims the groups
   -- SELECT StoreKey, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- WHERE DateKey BETWEEN 20090101 AND 20091231   -- filter rows first
   -- GROUP BY StoreKey
   -- HAVING SUM(SalesAmount) > 10000                -- then filter groups
   -- ORDER BY Revenue DESC;

   -- (b) HAVING with multiple conditions, just like WHERE
   -- SELECT StoreKey, COUNT(*) AS LineCount, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY StoreKey
   -- HAVING COUNT(*) > 50 AND SUM(SalesAmount) > 10000;

   -- (c) HAVING can also reference a plain grouped column, though
   --     that's really just acting like an extra WHERE at that point
   -- SELECT StoreKey, SUM(SalesAmount) AS Revenue
   -- FROM dbo.FactOnlineSales
   -- GROUP BY StoreKey
   -- HAVING StoreKey IN (199, 306, 259);
   ---------------------------------------------------------------- */


/* ================================================================
   ## 6.3 Exercises — GROUP BY / HAVING
   ================================================================ */

-- Exercise 6.1: For each ProductKey, show total SalesQuantity and total
-- SalesAmount, ordered by total SalesAmount descending.
-- Write your query below:


-- Solution:
-- SELECT ProductKey, SUM(SalesQuantity) AS TotalQty, SUM(SalesAmount) AS TotalAmount
-- FROM dbo.FactOnlineSales
-- GROUP BY ProductKey
-- ORDER BY TotalAmount DESC;

-- Exercise 6.2: Show only the CurrencyKey groups that have more than 50 sales lines.
-- Write your query below:


-- Solution:
-- SELECT CurrencyKey, COUNT(*) AS LineCount
-- FROM dbo.FactOnlineSales
-- GROUP BY CurrencyKey
-- HAVING COUNT(*) > 50;

-- Exercise 6.3: For each StoreKey, show the average SalesAmount, but only for
-- stores whose average sale is above $150.
-- Write your query below:


-- Solution:
-- SELECT StoreKey, AVG(SalesAmount) AS AvgSale
-- FROM dbo.FactOnlineSales
-- GROUP BY StoreKey
-- HAVING AVG(SalesAmount) > 150;

-- Exercise 6.4: Using ROLLUP, show total revenue per StoreKey PLUS one
-- grand-total row at the bottom.
-- Write your query below:


-- Solution:
-- SELECT StoreKey, SUM(SalesAmount) AS Revenue
-- FROM dbo.FactOnlineSales
-- GROUP BY ROLLUP (StoreKey)
-- ORDER BY StoreKey;
-- -- The final row (StoreKey = NULL) is the grand total across all stores.


/* ================================================================
   Continue to 07_DISTINCT_and_NULLs.sql next.
   ================================================================ */
