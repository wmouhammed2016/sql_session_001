/* ================================================================
   SQL-S8 STUDY GUIDE — PART 8: FINAL MIXED REVIEW
   Prerequisite: run 00_Setup.sql first.
   ================================================================
   Combine everything from Parts 1-7 in each exercise: DDL/DML,
   WHERE, aggregates, GROUP BY/HAVING, DISTINCT, and NULL handling.
   ================================================================ */

USE ContosoRetailDW;
GO


-- Exercise 8.1: Show the top 5 stores by total revenue, but only include
-- stores with more than 100 sales lines, ordered highest revenue first.
-- Write your query below:


-- Solution:
-- SELECT TOP 5 StoreKey, COUNT(*) AS LineCount, SUM(SalesAmount) AS Revenue
-- FROM dbo.FactOnlineSales
-- GROUP BY StoreKey
-- HAVING COUNT(*) > 100
-- ORDER BY Revenue DESC;


-- Exercise 8.2: Among sales made in 2009 (DateKey BETWEEN 20090101 AND 20091231)
-- with SalesQuantity >= 2, find the number of distinct customers and the
-- average sales amount.
-- Write your query below:


-- Solution:
-- SELECT COUNT(DISTINCT CustomerKey) AS UniqueCustomers, AVG(SalesAmount) AS AvgAmount
-- FROM dbo.FactOnlineSales
-- WHERE DateKey BETWEEN 20090101 AND 20091231
--   AND SalesQuantity >= 2;


-- Exercise 8.3: In dbo.FactOnlineSales_Practice, insert a new sale, update its
-- price, confirm it with a SELECT, then delete it — practicing the full DML cycle
-- (Part 3) inside a single transaction (Part 1), so it's all-or-nothing.
-- Write your query below:


-- Solution:
-- BEGIN TRANSACTION;
--     INSERT INTO dbo.FactOnlineSales_Practice
--         (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
--          CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
--          SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
--          DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
--     VALUES
--         (999005, 20091001, 199, 503, 1, 100, 20003, 'SO999005', 1,
--          1, 40.00, 0, 0, 0, 0, 20.00, 20.00, 40.00);
--
--     UPDATE dbo.FactOnlineSales_Practice SET UnitPrice = 45.00, SalesAmount = 45.00
--     WHERE OnlineSalesKey = 999005;
--
--     SELECT * FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999005;
--
--     DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999005;
-- COMMIT TRANSACTION;


-- Exercise 8.4: For each StoreKey, show total revenue and a "SafeAvgDiscount"
-- (average DiscountAmount with NULLs treated as 0, using COALESCE), but only
-- for stores with at least 50 sales lines, ordered by revenue descending.
-- This combines GROUP BY + HAVING + NULL-handling + aggregates in one query.
-- Write your query below:


-- Solution:
-- SELECT
--     StoreKey,
--     COUNT(*)                             AS LineCount,
--     SUM(SalesAmount)                     AS Revenue,
--     AVG(COALESCE(DiscountAmount, 0))     AS SafeAvgDiscount
-- FROM dbo.FactOnlineSales
-- GROUP BY StoreKey
-- HAVING COUNT(*) >= 50
-- ORDER BY Revenue DESC;


/* ================================================================
   ## CLEANUP (optional) — drop the practice table when fully done
   ================================================================ */
-- DROP TABLE IF EXISTS dbo.FactOnlineSales_Practice;


/* ================================================================
   You've now worked through every part of this study guide:
     00 Setup -> 01 Database Concepts -> 02 DDL -> 03 DML ->
     04 WHERE -> 05 Aggregate Functions -> 06 GROUP BY/HAVING ->
     07 DISTINCT + NULLs -> 08 Final Review (this file)
   See the README for a topic map back to the Lecture Agenda.
   ================================================================ */
