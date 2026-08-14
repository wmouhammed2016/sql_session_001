/* ================================================================
   SQL-S8 STUDY GUIDE
   Topics : Database Concepts, SQL DDL & DML — Foundations
            SQL Filtering & Aggregation
   Source : ContosoRetailDW  ->  dbo.FactOnlineSales
   How to use this file (notebook-style):
     - Blocks starting with "## " are explanation ("markdown cells")
     - Blocks under "Demo" are runnable code you should execute and read
     - Blocks under "Exercises" are for YOU to write in the blank space
     - Each exercise has a commented-out "Solution" right below it —
       try first, then uncomment (or just read) to check yourself
   ================================================================ */

-- If your Contoso database has a different name, change this line.
USE ContosoRetailDW;
GO


/* ================================================================
   ## 0. SETUP — a safe copy of FactOnlineSales to practice on
   ================================================================
   FactOnlineSales is real course data — we don't want to CREATE,
   ALTER, TRUNCATE, DROP, INSERT, UPDATE or DELETE on it directly.
   So we make a small practice copy. Re-run this block any time you
   want to reset your practice table back to a clean state.
   ================================================================ */

-- Demo
DROP TABLE IF EXISTS dbo.FactOnlineSales_Practice;
GO

SELECT TOP (1000)
    OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
    CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
    SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
    DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice
INTO dbo.FactOnlineSales_Practice
FROM dbo.FactOnlineSales;
GO

SELECT COUNT(*) AS PracticeRowCount FROM dbo.FactOnlineSales_Practice;
GO


/* ================================================================
   ## 1. DATABASE CONCEPTS
   ================================================================
   - DBMS (Database Management System): software that stores,
     organizes, and controls access to data (e.g. SQL Server).
   - Schema: the blueprint of the database — tables, columns, data
     types, and the relationships between them (here: "dbo").
   - Transaction: one or more statements executed as a single unit
     of work — either ALL of it succeeds (COMMIT) or NONE of it
     does (ROLLBACK). Keeps data consistent even if something fails
     halfway through (e.g. an order INSERT + an inventory UPDATE).
   - File-based systems (flat .csv/.txt files) vs relational DBs:
       * No enforced structure/data types  -> DB enforces both
       * Duplicate data everywhere         -> DB normalizes data
       * No relationships between files    -> DB uses keys (FKs)
       * No concurrent-access safety       -> DB handles multi-user
         locking & transactions
       * Hard to query/filter/aggregate    -> SQL does this natively
   FactOnlineSales itself is a great example of *why* relational
   design matters: instead of repeating product/store/customer
   details on every sales row, it stores just the KEYS
   (ProductKey, StoreKey, CustomerKey...) pointing to dimension
   tables (DimProduct, DimStore, DimCustomer...) — no duplication.
   ================================================================ */


/* ================================================================
   ## 2. DDL — DATA DEFINITION LANGUAGE
   DDL defines/changes the STRUCTURE of the database: tables,
   columns, data types, constraints. It does NOT touch row data.
   ================================================================ */

-- --------------------------------------------------------------
-- ## 2.1 CREATE TABLE — data types & constraints
-- --------------------------------------------------------------
-- Demo: a small staging table modeled after FactOnlineSales,
-- written out explicitly so you can see each data type/constraint.
DROP TABLE IF EXISTS dbo.OnlineSales_Staging;
GO

CREATE TABLE dbo.OnlineSales_Staging (
    StagingID           INT IDENTITY(1,1) PRIMARY KEY,   -- auto-incrementing key
    SalesOrderNumber     NVARCHAR(20)  NOT NULL,          -- required text
    SalesOrderLineNumber INT           NOT NULL,
    ProductKey           INT           NOT NULL,
    SalesQuantity         INT           NOT NULL DEFAULT 1,
    UnitPrice             MONEY         NOT NULL CHECK (UnitPrice >= 0),
    DiscountAmount         MONEY         NULL DEFAULT 0,   -- optional, defaults to 0
    LoadedAt               DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

-- Inspect the structure we just created:
EXEC sp_help 'dbo.OnlineSales_Staging';
GO

-- --------------------------------------------------------------
-- ## 2.2 ALTER TABLE — change an existing structure
-- --------------------------------------------------------------
-- Demo: add a column, widen a column, add a constraint, drop a column
ALTER TABLE dbo.OnlineSales_Staging ADD Currency NVARCHAR(3) NULL;
GO

ALTER TABLE dbo.OnlineSales_Staging ALTER COLUMN SalesOrderNumber NVARCHAR(30) NOT NULL;
GO

ALTER TABLE dbo.OnlineSales_Staging ADD CONSTRAINT DF_Currency DEFAULT ('USD') FOR Currency;
GO

ALTER TABLE dbo.OnlineSales_Staging DROP COLUMN LoadedAt;
GO

EXEC sp_help 'dbo.OnlineSales_Staging';
GO

-- --------------------------------------------------------------
-- ## 2.3 TRUNCATE TABLE vs DROP TABLE
-- --------------------------------------------------------------
-- TRUNCATE removes ALL rows fast (resets identity), keeps the
-- table structure. Cannot be filtered with WHERE.
-- Demo (on the PRACTICE fact table copy, not staging):
SELECT COUNT(*) AS RowsBeforeTruncate FROM dbo.FactOnlineSales_Practice;
GO
TRUNCATE TABLE dbo.FactOnlineSales_Practice;
GO
SELECT COUNT(*) AS RowsAfterTruncate FROM dbo.FactOnlineSales_Practice;
GO

-- Rebuild the practice table for the rest of this file:
DROP TABLE IF EXISTS dbo.FactOnlineSales_Practice;
GO
SELECT TOP (1000)
    OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
    CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
    SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
    DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice
INTO dbo.FactOnlineSales_Practice
FROM dbo.FactOnlineSales;
GO

-- DROP removes the table AND its structure completely.
-- Demo: drop the staging table now that we're done with it.
DROP TABLE IF EXISTS dbo.OnlineSales_Staging;
GO

-- --------------------------------------------------------------
-- ## 2.4 Exercises — DDL
-- --------------------------------------------------------------

-- Exercise 2.1: Create a table dbo.Ex_ReturnLog with columns:
--   ReturnLogID (auto-incrementing PK), OnlineSalesKey (INT, required),
--   ReturnQuantity (INT, required, must be > 0), ReturnReason (NVARCHAR(100), optional)
-- Write your query below:


-- Solution:
-- CREATE TABLE dbo.Ex_ReturnLog (
--     ReturnLogID    INT IDENTITY(1,1) PRIMARY KEY,
--     OnlineSalesKey INT NOT NULL,
--     ReturnQuantity INT NOT NULL CHECK (ReturnQuantity > 0),
--     ReturnReason   NVARCHAR(100) NULL
-- );

-- Exercise 2.2: Add a column LoggedDate (DATETIME) to dbo.Ex_ReturnLog
-- with a default of the current date/time.
-- Write your query below:


-- Solution:
-- ALTER TABLE dbo.Ex_ReturnLog ADD LoggedDate DATETIME NOT NULL DEFAULT GETDATE();

-- Exercise 2.3: Empty out dbo.FactOnlineSales_Practice completely and as fast
-- as possible, keeping its structure. Which command did you use, and why not DELETE?
-- Write your query below:


-- Solution:
-- TRUNCATE TABLE dbo.FactOnlineSales_Practice;
-- -- TRUNCATE is faster than DELETE for wiping ALL rows because it doesn't log
-- -- individual row deletions and resets identity columns.
-- -- (Remember to rebuild the practice table afterwards using the setup block!)

-- Exercise 2.4: Permanently remove dbo.Ex_ReturnLog from the database.
-- Write your query below:


-- Solution:
-- DROP TABLE IF EXISTS dbo.Ex_ReturnLog;


/* ================================================================
   ## 3. DML — DATA MANIPULATION LANGUAGE
   DML works with the ROW DATA inside tables: reading it and
   changing it. Structure stays the same.
   ================================================================ */

-- --------------------------------------------------------------
-- ## 3.1 SELECT DISTINCT
-- --------------------------------------------------------------
-- Demo: which currencies actually appear in online sales?
SELECT DISTINCT CurrencyKey
FROM dbo.FactOnlineSales;
GO

-- --------------------------------------------------------------
-- ## 3.2 INSERT INTO
-- --------------------------------------------------------------
-- Demo: log a manual sale into the practice table.
-- Note: OnlineSalesKey is left out on purpose to show a NULL PromotionKey below.
INSERT INTO dbo.FactOnlineSales_Practice
    (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
     CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
     SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
     DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
VALUES
    (999001, 20090615, 199, 350, NULL,
     100, 19998, 'SO999001', 1,
     2, 199.98, 0, 0,
     0, NULL, 120.00, 60.00, 99.99);
GO

-- --------------------------------------------------------------
-- ## 3.3 UPDATE
-- --------------------------------------------------------------
-- Demo: correct the price on the row we just inserted.
UPDATE dbo.FactOnlineSales_Practice
SET UnitPrice = 89.99,
    SalesAmount = 179.98
WHERE OnlineSalesKey = 999001;
GO

-- --------------------------------------------------------------
-- ## 3.4 DELETE
-- --------------------------------------------------------------
-- Demo: remove that manual test row.
DELETE FROM dbo.FactOnlineSales_Practice
WHERE OnlineSalesKey = 999001;
GO

-- --------------------------------------------------------------
-- ## 3.5 Exercises — DML
-- --------------------------------------------------------------

-- Exercise 3.1: List the distinct StoreKey values in dbo.FactOnlineSales.
-- Write your query below:


-- Solution:
-- SELECT DISTINCT StoreKey FROM dbo.FactOnlineSales;

-- Exercise 3.2: Insert a new row into dbo.FactOnlineSales_Practice with
-- OnlineSalesKey = 999002, ProductKey = 500, SalesQuantity = 1,
-- UnitPrice = 25.00, SalesAmount = 25.00, and NULL for DiscountAmount.
-- (Fill any other required columns with reasonable values.)
-- Write your query below:


-- Solution:
-- INSERT INTO dbo.FactOnlineSales_Practice
--     (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
--      CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
--      SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
--      DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
-- VALUES
--     (999002, 20090701, 199, 500, 1,
--      100, 19999, 'SO999002', 1,
--      1, 25.00, 0, 0,
--      0, NULL, 15.00, 15.00, 25.00);

-- Exercise 3.3: Give a 10% discount (DiscountAmount) on the row you just
-- inserted (OnlineSalesKey = 999002).
-- Write your query below:


-- Solution:
-- UPDATE dbo.FactOnlineSales_Practice
-- SET DiscountAmount = SalesAmount * 0.10
-- WHERE OnlineSalesKey = 999002;

-- Exercise 3.4: Delete the row with OnlineSalesKey = 999002.
-- Write your query below:


-- Solution:
-- DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999002;


/* ================================================================
   ## 4. DDL vs DML — RECAP
   ================================================================
   DDL = structure  (CREATE, ALTER, DROP, TRUNCATE) — changes what
         the table LOOKS like.
   DML  = data       (SELECT, INSERT, UPDATE, DELETE) — changes/reads
         what's INSIDE the table.
   In a data analysis workflow you typically: design/adjust
   structure with DDL once, then repeatedly load, clean, and query
   data with DML/SELECT as the day-to-day work.
   ================================================================ */


/* ================================================================
   ## 5. WHERE — FILTERING ROWS
   ================================================================ */

-- --------------------------------------------------------------
-- ## 5.1 Comparison operators
-- --------------------------------------------------------------
-- Demo: sales lines worth more than $500
SELECT OnlineSalesKey, ProductKey, SalesAmount
FROM dbo.FactOnlineSales
WHERE SalesAmount > 500;
GO

-- --------------------------------------------------------------
-- ## 5.2 AND / OR / NOT
-- --------------------------------------------------------------
-- Demo: big-ticket, high-quantity lines that were NOT discounted
SELECT OnlineSalesKey, SalesQuantity, SalesAmount, DiscountAmount
FROM dbo.FactOnlineSales
WHERE SalesAmount > 500
  AND SalesQuantity >= 2
  AND NOT DiscountAmount > 0;
GO

-- --------------------------------------------------------------
-- ## 5.3 IN
-- --------------------------------------------------------------
-- Demo: sales from a specific set of stores
SELECT OnlineSalesKey, StoreKey, SalesAmount
FROM dbo.FactOnlineSales
WHERE StoreKey IN (199, 306, 259);
GO

-- --------------------------------------------------------------
-- ## 5.4 BETWEEN
-- --------------------------------------------------------------
-- Note: DateKey is a surrogate integer key shaped like YYYYMMDD,
-- not a real DATE column — that's a common data-warehouse pattern.
-- Demo: sales during 2009
SELECT OnlineSalesKey, DateKey, SalesAmount
FROM dbo.FactOnlineSales
WHERE DateKey BETWEEN 20090101 AND 20091231;
GO

-- --------------------------------------------------------------
-- ## 5.5 LIKE
-- --------------------------------------------------------------
-- Demo: order numbers that start with 'SO4'
SELECT DISTINCT SalesOrderNumber
FROM dbo.FactOnlineSales
WHERE SalesOrderNumber LIKE 'SO4%';
GO

-- --------------------------------------------------------------
-- ## 5.6 Exercises — WHERE
-- --------------------------------------------------------------

-- Exercise 5.1: Find all sales lines with SalesQuantity greater than 5.
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales WHERE SalesQuantity > 5;

-- Exercise 5.2: Find sales lines where SalesAmount is between 100 and 300
-- AND there was a return (ReturnQuantity > 0).
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales
-- WHERE SalesAmount BETWEEN 100 AND 300
--   AND ReturnQuantity > 0;

-- Exercise 5.3: Find sales lines from store 199 OR store 306 with no discount.
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales
-- WHERE (StoreKey = 199 OR StoreKey = 306)
--   AND DiscountAmount = 0;

-- Exercise 5.4: Find all distinct SalesOrderNumbers that contain '99' anywhere.
-- Write your query below:


-- Solution:
-- SELECT DISTINCT SalesOrderNumber FROM dbo.FactOnlineSales
-- WHERE SalesOrderNumber LIKE '%99%';


/* ================================================================
   ## 6. AGGREGATE FUNCTIONS
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

-- --------------------------------------------------------------
-- ## 6.1 Exercises — Aggregate functions
-- --------------------------------------------------------------

-- Exercise 6.1: How many sales lines resulted in a return (ReturnQuantity > 0)?
-- Write your query below:


-- Solution:
-- SELECT COUNT(*) AS LinesWithReturns
-- FROM dbo.FactOnlineSales
-- WHERE ReturnQuantity > 0;

-- Exercise 6.2: What is the total SalesQuantity sold across all lines?
-- Write your query below:


-- Solution:
-- SELECT SUM(SalesQuantity) AS TotalUnitsSold FROM dbo.FactOnlineSales;

-- Exercise 6.3: What is the average UnitPrice, and what are the min/max UnitPrice?
-- Write your query below:


-- Solution:
-- SELECT AVG(UnitPrice) AS AvgUnitPrice, MIN(UnitPrice) AS MinUnitPrice,
--        MAX(UnitPrice) AS MaxUnitPrice
-- FROM dbo.FactOnlineSales;


/* ================================================================
   ## 7. GROUP BY and HAVING
   ================================================================ */

-- --------------------------------------------------------------
-- ## 7.1 GROUP BY — aggregate per group
-- --------------------------------------------------------------
-- Demo: revenue and line count per store
SELECT
    StoreKey,
    COUNT(*)         AS LineCount,
    SUM(SalesAmount) AS Revenue
FROM dbo.FactOnlineSales
GROUP BY StoreKey
ORDER BY Revenue DESC;
GO

-- --------------------------------------------------------------
-- ## 7.2 HAVING — filter the GROUPS (not the raw rows)
-- --------------------------------------------------------------
-- Demo: only stores with more than $10,000 in revenue
SELECT
    StoreKey,
    SUM(SalesAmount) AS Revenue
FROM dbo.FactOnlineSales
GROUP BY StoreKey
HAVING SUM(SalesAmount) > 10000
ORDER BY Revenue DESC;
GO

-- --------------------------------------------------------------
-- ## 7.3 Exercises — GROUP BY / HAVING
-- --------------------------------------------------------------

-- Exercise 7.1: For each ProductKey, show total SalesQuantity and total
-- SalesAmount, ordered by total SalesAmount descending.
-- Write your query below:


-- Solution:
-- SELECT ProductKey, SUM(SalesQuantity) AS TotalQty, SUM(SalesAmount) AS TotalAmount
-- FROM dbo.FactOnlineSales
-- GROUP BY ProductKey
-- ORDER BY TotalAmount DESC;

-- Exercise 7.2: Show only the CurrencyKey groups that have more than 50 sales lines.
-- Write your query below:


-- Solution:
-- SELECT CurrencyKey, COUNT(*) AS LineCount
-- FROM dbo.FactOnlineSales
-- GROUP BY CurrencyKey
-- HAVING COUNT(*) > 50;

-- Exercise 7.3: For each StoreKey, show the average SalesAmount, but only for
-- stores whose average sale is above $150.
-- Write your query below:


-- Solution:
-- SELECT StoreKey, AVG(SalesAmount) AS AvgSale
-- FROM dbo.FactOnlineSales
-- GROUP BY StoreKey
-- HAVING AVG(SalesAmount) > 150;


/* ================================================================
   ## 8. DISTINCT WITH AGGREGATES + NULL HANDLING
   ================================================================ */

-- --------------------------------------------------------------
-- ## 8.1 COUNT(DISTINCT column)
-- --------------------------------------------------------------
-- Demo: how many unique customers bought something online?
SELECT COUNT(DISTINCT CustomerKey) AS UniqueCustomers
FROM dbo.FactOnlineSales;
GO

-- --------------------------------------------------------------
-- ## 8.2 NULLs in aggregation
-- --------------------------------------------------------------
-- Aggregate functions (SUM, AVG, MIN, MAX, COUNT(column)) IGNORE NULLs.
-- COUNT(*) counts rows regardless of NULLs; COUNT(column) does not
-- count rows where that column is NULL.
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

-- --------------------------------------------------------------
-- ## 8.3 Exercises — DISTINCT + NULLs
-- --------------------------------------------------------------

-- Exercise 8.1: How many distinct ProductKeys appear in FactOnlineSales?
-- Write your query below:


-- Solution:
-- SELECT COUNT(DISTINCT ProductKey) AS UniqueProducts FROM dbo.FactOnlineSales;

-- Exercise 8.2: Insert a practice row (any key, e.g. 999004) with SalesAmount = 75
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

-- Exercise 8.3: Using COALESCE, show SalesAmount and a "SafeDiscount" column
-- that replaces NULL DiscountAmount with 0 for the first 20 rows of FactOnlineSales.
-- Write your query below:


-- Solution:
-- SELECT TOP 20 SalesAmount, COALESCE(DiscountAmount, 0) AS SafeDiscount
-- FROM dbo.FactOnlineSales;


/* ================================================================
   ## 9. FINAL MIXED REVIEW
   Combine everything from this session in one query each.
   ================================================================ */

-- Exercise 9.1: Show the top 5 stores by total revenue, but only include
-- stores with more than 100 sales lines, ordered highest revenue first.
-- Write your query below:


-- Solution:
-- SELECT TOP 5 StoreKey, COUNT(*) AS LineCount, SUM(SalesAmount) AS Revenue
-- FROM dbo.FactOnlineSales
-- GROUP BY StoreKey
-- HAVING COUNT(*) > 100
-- ORDER BY Revenue DESC;

-- Exercise 9.2: Among sales made in 2009 (DateKey BETWEEN 20090101 AND 20091231)
-- with SalesQuantity >= 2, find the number of distinct customers and the
-- average sales amount.
-- Write your query below:


-- Solution:
-- SELECT COUNT(DISTINCT CustomerKey) AS UniqueCustomers, AVG(SalesAmount) AS AvgAmount
-- FROM dbo.FactOnlineSales
-- WHERE DateKey BETWEEN 20090101 AND 20091231
--   AND SalesQuantity >= 2;

-- Exercise 9.3: In dbo.FactOnlineSales_Practice, insert a new sale, update its
-- price, confirm it with a SELECT, then delete it — practicing the full DML cycle.
-- Write your query below:


-- Solution:
-- INSERT INTO dbo.FactOnlineSales_Practice
--     (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
--      CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
--      SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
--      DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
-- VALUES
--     (999005, 20091001, 199, 503, 1, 100, 20003, 'SO999005', 1,
--      1, 40.00, 0, 0, 0, 0, 20.00, 20.00, 40.00);
--
-- UPDATE dbo.FactOnlineSales_Practice SET UnitPrice = 45.00, SalesAmount = 45.00
-- WHERE OnlineSalesKey = 999005;
--
-- SELECT * FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999005;
--
-- DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 999005;


/* ================================================================
   ## CLEANUP (optional) — drop the practice table when fully done
   ================================================================ */
-- DROP TABLE IF EXISTS dbo.FactOnlineSales_Practice;
