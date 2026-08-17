/* ================================================================
   SQL-S8 STUDY GUIDE — PART 0: SETUP
   ================================================================
   Run the parts IN ORDER (00 -> 08) in a new query window each
   time, or re-run this Part 0 whenever you want to reset your
   practice table to a clean state.

   Source database : ContosoRetailDW
   Source table     : dbo.FactOnlineSales

   How to use these files (notebook-style):
     - Blocks starting with "## " are explanation ("markdown cells")
     - Blocks under "Demo"       are runnable code you should execute and read
     - Blocks under "Variations" show other forms of the same statement —
       read them, and try running the ones that are safe to run
     - Blocks under "Exercises"  are for YOU to write in the blank space
     - Each exercise has a commented-out "Solution" right below it —
       try first, then uncomment (or just read) to check yourself
   ================================================================ */

-- If your Contoso database has a different name, change this line.
USE ContosoRetailDW;
GO


/* ================================================================
   ## 0.1 WHY A PRACTICE COPY?
   ================================================================
   FactOnlineSales is real course data — we don't want to CREATE,
   ALTER, TRUNCATE, DROP, INSERT, UPDATE or DELETE on it directly.
   So every part of this guide that changes data works against a
   small practice copy instead: dbo.FactOnlineSales_Practice.
   Re-run this block any time you want to reset it to a clean state.
   ================================================================ */

-- Demo
DROP TABLE IF EXISTS dbo.FactOnlineSales_Practice;
GO

SELECT TOP (1000)
   -- Selected ONLY the data columns and excluding the META DATA columns.
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
   ## 0.2 VARIATIONS — other ways to copy/seed data into a table
   ================================================================
   The block above uses SELECT ... INTO, which is really a DDL +
   DML combo: it CREATEs a brand-new table AND populates it, in one
   statement, with column names/types inferred from the query.
   That's different from INSERT INTO ... SELECT (Part 3), which
   requires the target table to already exist.

   Other common ways to seed a table with starting data:

   -- (a) SELECT INTO with a filter — only copy a subset of rows
   -- SELECT * INTO dbo.FactOnlineSales_2009
   -- FROM dbo.FactOnlineSales
   -- WHERE DateKey BETWEEN 20090101 AND 20091231;

   -- (b) INSERT INTO ... SELECT — table must exist first
   -- INSERT INTO dbo.FactOnlineSales_Practice
   -- SELECT TOP (500) * FROM dbo.FactOnlineSales
   -- WHERE StoreKey = 199;

   -- (c) Table variable — lives only for this batch/procedure,
   --     good for small, temporary, in-memory-ish result sets
   -- DECLARE @RecentSales TABLE (OnlineSalesKey INT, SalesAmount MONEY);
   -- INSERT INTO @RecentSales SELECT OnlineSalesKey, SalesAmount
   -- FROM dbo.FactOnlineSales WHERE DateKey > 20090601;

   -- (d) Local temp table — lives for the whole session, visible
   --     only to it, dropped automatically when the session ends
   -- SELECT * INTO #TempSales FROM dbo.FactOnlineSales WHERE StoreKey = 199;
   -- (a "##" prefix instead of "#" makes it a GLOBAL temp table,
   --  visible to every session until all of them disconnect)
   ================================================================ */


/* ================================================================
   Continue to 01_Database_Concepts.sql next.
   ================================================================ */
