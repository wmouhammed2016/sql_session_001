/* ================================================================
   SQL-S8 STUDY GUIDE — PART 3: DML (DATA MANIPULATION LANGUAGE)
   Prerequisite: run 00_Setup.sql first.
   ================================================================
   DML works with the ROW DATA inside tables: reading it and
   changing it. Structure stays the same.
   Statements covered: SELECT DISTINCT, INSERT INTO, UPDATE, DELETE.
   ================================================================ */

USE ContosoRetailDW;
GO


/* ================================================================
   ## 3.1 SELECT DISTINCT
   ================================================================ */

-- Demo: which currencies actually appear in online sales?
SELECT DISTINCT CurrencyKey
FROM dbo.FactOnlineSales;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) DISTINCT across multiple columns — keeps unique
   --     COMBINATIONS, not unique values per column
   -- SELECT DISTINCT StoreKey, CurrencyKey FROM dbo.FactOnlineSales;

   -- (b) DISTINCT with an expression
   -- SELECT DISTINCT CAST(DateKey / 10000 AS INT) AS SalesYear
   -- FROM dbo.FactOnlineSales;

   -- (c) COUNT(DISTINCT column) — count unique values instead of
   --     listing them (covered in depth in Part 7)
   -- SELECT COUNT(DISTINCT CurrencyKey) AS DistinctCurrencies FROM dbo.FactOnlineSales;

   -- (d) DISTINCT vs GROUP BY — for a plain "unique list", they're
   --     equivalent; GROUP BY is used when you also need per-group
   --     aggregates (SUM, COUNT, etc. — see Parts 5-6), DISTINCT is
   --     for "just the unique rows/values, no math."
   -- SELECT StoreKey FROM dbo.FactOnlineSales GROUP BY StoreKey;  -- same rows as DISTINCT StoreKey

   -- (e) SELECT DISTINCT TOP(n) — unique values, capped to n rows
   -- SELECT DISTINCT TOP (5) StoreKey FROM dbo.FactOnlineSales;
   ---------------------------------------------------------------- */


/* ================================================================
   ## 3.2 INSERT INTO
   ================================================================ */

-- Demo: log a manual sale into the practice table.
-- Note: PromotionKey is set to NULL on purpose, to show a NULL value.
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

/* ----------------------------------------------------------------
   Variations:

   -- (a) Multi-row INSERT — one statement, several VALUES tuples
   -- INSERT INTO dbo.FactOnlineSales_Practice
   --     (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
   --      CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
   --      SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
   --      DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
   -- VALUES
   --     (999006, 20091101, 199, 350, NULL, 100, 19998, 'SO999006', 1, 1, 50, 0, 0, 0, 0, 30, 30, 50),
   --     (999007, 20091101, 199, 351, NULL, 100, 19998, 'SO999007', 1, 1, 60, 0, 0, 0, 0, 35, 35, 60);

   -- (b) INSERT INTO ... SELECT — copy rows from another query
   --     (the target table must already exist; compare with
   --     SELECT ... INTO in 00_Setup.sql, which CREATES the table)
   -- INSERT INTO dbo.FactOnlineSales_Practice
   -- SELECT TOP (10) * FROM dbo.FactOnlineSales WHERE StoreKey = 306;

   -- (c) INSERT ... OUTPUT — see the row(s) you just inserted,
   --     without a separate SELECT
   -- INSERT INTO dbo.FactOnlineSales_Practice (OnlineSalesKey, DateKey, StoreKey,
   --     ProductKey, CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
   --     SalesQuantity, SalesAmount)
   -- OUTPUT INSERTED.OnlineSalesKey, INSERTED.SalesAmount
   -- VALUES (999008, 20091101, 199, 350, 100, 19998, 'SO999008', 1, 1, 75);

   -- (d) MERGE — "upsert" in one statement: insert if the row is
   --     new, update it if it already exists. A brief preview:
   -- MERGE dbo.FactOnlineSales_Practice AS target
   -- USING (SELECT 999001 AS OnlineSalesKey, 210.00 AS SalesAmount) AS src
   --     ON target.OnlineSalesKey = src.OnlineSalesKey
   -- WHEN MATCHED THEN UPDATE SET target.SalesAmount = src.SalesAmount
   -- WHEN NOT MATCHED THEN
   --     INSERT (OnlineSalesKey, SalesAmount) VALUES (src.OnlineSalesKey, src.SalesAmount);
   ---------------------------------------------------------------- */


/* ================================================================
   ## 3.3 UPDATE
   ================================================================ */

-- Demo: correct the price on the row we just inserted.
UPDATE dbo.FactOnlineSales_Practice
SET UnitPrice = 89.99,
    SalesAmount = 179.98
WHERE OnlineSalesKey = 999001;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) UPDATE with a CASE expression — different new values
   --     depending on a condition, all in one statement
   -- UPDATE dbo.FactOnlineSales_Practice
   -- SET DiscountAmount = CASE
   --         WHEN SalesAmount > 150 THEN SalesAmount * 0.10
   --         ELSE 0
   --     END;

   -- (b) UPDATE ... FROM ... JOIN — update rows based on values
   --     from ANOTHER table (here, pulling a real price from DimProduct)
   -- UPDATE p
   -- SET p.UnitPrice = d.ProductSubcategoryKey  -- (example shape only)
   -- FROM dbo.FactOnlineSales_Practice AS p
   -- JOIN dbo.DimProduct AS d ON p.ProductKey = d.ProductKey
   -- WHERE p.OnlineSalesKey = 999001;

   -- (c) UPDATE TOP (n) — only update the first n matching rows
   -- UPDATE TOP (5) dbo.FactOnlineSales_Practice
   -- SET DiscountAmount = 0
   -- WHERE DiscountAmount IS NULL;

   -- (d) UPDATE ... OUTPUT — see before/after values in one go
   -- UPDATE dbo.FactOnlineSales_Practice
   -- SET UnitPrice = 95.00
   -- OUTPUT DELETED.UnitPrice AS OldPrice, INSERTED.UnitPrice AS NewPrice
   -- WHERE OnlineSalesKey = 999001;
   ---------------------------------------------------------------- */


/* ================================================================
   ## 3.4 DELETE
   ================================================================ */

-- Demo: remove that manual test row.
DELETE FROM dbo.FactOnlineSales_Practice
WHERE OnlineSalesKey = 999001;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) DELETE ... FROM ... JOIN — delete rows based on a
   --     condition in another table
   -- DELETE p
   -- FROM dbo.FactOnlineSales_Practice AS p
   -- JOIN dbo.DimStore AS s ON p.StoreKey = s.StoreKey
   -- WHERE s.StoreName = 'Some Closed Store';

   -- (b) DELETE TOP (n) — only delete the first n matching rows
   -- DELETE TOP (100) FROM dbo.FactOnlineSales_Practice WHERE ReturnQuantity > 0;

   -- (c) DELETE ... OUTPUT — capture what was removed (handy for
   --     an audit log/undo trail)
   -- DELETE FROM dbo.FactOnlineSales_Practice
   -- OUTPUT DELETED.*
   -- WHERE OnlineSalesKey = 999001;

   -- (d) DELETE with no WHERE removes every row (fully logged) —
   --     for wiping an ENTIRE table, TRUNCATE is faster (see Part 2).

   -- (e) ON DELETE CASCADE — if a FOREIGN KEY is defined with this
   --     option, deleting a parent row (e.g. a DimProduct row)
   --     automatically deletes matching child rows too. Powerful,
   --     but dangerous if used carelessly.
   ---------------------------------------------------------------- */


/* ================================================================
   ## 3.5 Exercises — DML
   ================================================================ */

-- Exercise 3.1: List the distinct StoreKey values in dbo.FactOnlineSales.
-- Write your query below:


-- Solution:
-- SELECT DISTINCT StoreKey FROM dbo.FactOnlineSales;

-- Exercise 3.2: Insert TWO new rows into dbo.FactOnlineSales_Practice in a
-- single INSERT statement: OnlineSalesKey 999002 and 999003, ProductKey 500,
-- SalesQuantity 1, UnitPrice 25.00, SalesAmount 25.00, NULL DiscountAmount.
-- (Fill any other required columns with reasonable values.)
-- Write your query below:


-- Solution:
-- INSERT INTO dbo.FactOnlineSales_Practice
--     (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
--      CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
--      SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
--      DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
-- VALUES
--     (999002, 20090701, 199, 500, 1, 100, 19999, 'SO999002', 1, 1, 25.00, 0, 0, 0, NULL, 15.00, 15.00, 25.00),
--     (999003, 20090701, 199, 500, 1, 100, 20000, 'SO999003', 1, 1, 25.00, 0, 0, 0, NULL, 15.00, 15.00, 25.00);

-- Exercise 3.3: Give a 10% discount (DiscountAmount) on both rows you just
-- inserted (OnlineSalesKey 999002 and 999003), using IN instead of two
-- separate UPDATE statements.
-- Write your query below:


-- Solution:
-- UPDATE dbo.FactOnlineSales_Practice
-- SET DiscountAmount = SalesAmount * 0.10
-- WHERE OnlineSalesKey IN (999002, 999003);

-- Exercise 3.4: Delete both rows (999002 and 999003) in a single DELETE.
-- Write your query below:


-- Solution:
-- DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey IN (999002, 999003);


/* ================================================================
   ## 3.6 DDL vs DML — RECAP
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
   Continue to 04_WHERE_Filtering.sql next.
   ================================================================ */
