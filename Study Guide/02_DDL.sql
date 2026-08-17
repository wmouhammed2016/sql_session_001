/* ================================================================
   SQL-S8 STUDY GUIDE — PART 2: DDL (DATA DEFINITION LANGUAGE)
   Prerequisite: run 00_Setup.sql first.
   ================================================================
   DDL defines/changes the STRUCTURE of the database: tables,
   columns, data types, constraints. It does NOT touch row data.
   Statements covered: CREATE TABLE, ALTER TABLE, DROP TABLE,
   TRUNCATE TABLE.
   ================================================================ */

USE ContosoRetailDW;
GO


/* ================================================================
   ## 2.1 CREATE TABLE — data types & constraints
   ================================================================ */

-- Demo: a small staging table modeled after FactOnlineSales,
-- written out explicitly so you can see each data type/constraint.
DROP TABLE IF EXISTS dbo.OnlineSales_Staging;
GO

CREATE TABLE dbo.OnlineSales_Staging (
    StagingID            INT IDENTITY(1,1) PRIMARY KEY,   -- auto-incrementing key
    SalesOrderNumber      NVARCHAR(20)  NOT NULL,          -- required text
    SalesOrderLineNumber  INT           NOT NULL,
    ProductKey            INT           NOT NULL,
    SalesQuantity         INT           NOT NULL DEFAULT 1,
    UnitPrice              MONEY         NOT NULL CHECK (UnitPrice >= 0),
    DiscountAmount          MONEY         NULL DEFAULT 0,   -- optional, defaults to 0
    LoadedAt DATETIME NOT NULL CONSTRAINT DF_Staging_LoadedAt DEFAULT GETDATE()

);
GO

-- Inspect the structure we just created:
EXEC sp_help 'dbo.OnlineSales_Staging';
GO

/* ----------------------------------------------------------------
   Variations — other things CREATE TABLE can express:

   -- (a) Composite primary key (two or more columns together
   --     uniquely identify a row — this mirrors how FactOnlineSales
   --     is really keyed by SalesOrderNumber + SalesOrderLineNumber)
   -- CREATE TABLE dbo.Ex_OrderLines (
   --     SalesOrderNumber     NVARCHAR(20) NOT NULL,
   --     SalesOrderLineNumber INT          NOT NULL,
   --     ProductKey           INT          NOT NULL,
   --     CONSTRAINT PK_OrderLines PRIMARY KEY (SalesOrderNumber, SalesOrderLineNumber)
   -- );

   -- (b) FOREIGN KEY — enforce that ProductKey must exist in DimProduct,
   --     with an action to take if the parent row is deleted/changed
   -- CREATE TABLE dbo.Ex_StagingWithFK (
   --     StagingID  INT IDENTITY(1,1) PRIMARY KEY,
   --     ProductKey INT NOT NULL,
   --     CONSTRAINT FK_Staging_Product FOREIGN KEY (ProductKey)
   --         REFERENCES dbo.DimProduct(ProductKey)
   --         ON DELETE NO ACTION   -- other options: CASCADE, SET NULL, SET DEFAULT
   --         ON UPDATE NO ACTION
   -- );

   -- (c) UNIQUE constraint — like PRIMARY KEY, but allows one NULL
   --     and a table can have several UNIQUE constraints
   -- CREATE TABLE dbo.Ex_Currencies (
   --     CurrencyKey  INT PRIMARY KEY,
   --     CurrencyCode CHAR(3) NOT NULL UNIQUE
   -- );

   -- (d) "CREATE TABLE IF NOT EXISTS" isn't valid T-SQL syntax the
   --     way it is in MySQL/PostgreSQL. In SQL Server the equivalent
   --     guard is:
   -- IF OBJECT_ID('dbo.OnlineSales_Staging', 'U') IS NULL
   -- BEGIN
   --     CREATE TABLE dbo.OnlineSales_Staging (StagingID INT PRIMARY KEY);
   -- END;

   -- (e) CREATE TABLE from a query's shape, in one shot — this is
   --     what SELECT ... INTO does (see 00_Setup.sql). There is no
   --     separate "CREATE TABLE AS SELECT" keyword in T-SQL like
   --     there is in PostgreSQL/MySQL — SELECT ... INTO is the
   --     T-SQL equivalent.
   ---------------------------------------------------------------- */


/* ================================================================
   ## 2.2 ALTER TABLE — change an existing structure
   ================================================================ */

-- Demo: add a column, widen a column, add a constraint, drop a column
ALTER TABLE dbo.OnlineSales_Staging ADD Currency NVARCHAR(3) NULL;
GO

ALTER TABLE dbo.OnlineSales_Staging ALTER COLUMN SalesOrderNumber NVARCHAR(30) NOT NULL;
GO

ALTER TABLE dbo.OnlineSales_Staging ADD CONSTRAINT DF_Currency DEFAULT ('USD') FOR Currency;
GO

ALTER TABLE dbo.OnlineSales_Staging DROP CONSTRAINT DF_Staging_LoadedAt;
ALTER TABLE dbo.OnlineSales_Staging DROP COLUMN LoadedAt;
GO

EXEC sp_help 'dbo.OnlineSales_Staging';
GO

/* ----------------------------------------------------------------
   Variations — other ALTER TABLE moves:

   -- (a) Add several columns in a single statement
   -- ALTER TABLE dbo.OnlineSales_Staging
   --     ADD Notes NVARCHAR(200) NULL, ReviewedBy NVARCHAR(50) NULL;

   -- (b) Add / drop a constraint by name
   -- ALTER TABLE dbo.OnlineSales_Staging ADD CONSTRAINT CK_Qty CHECK (SalesQuantity > 0);
   -- ALTER TABLE dbo.OnlineSales_Staging DROP CONSTRAINT CK_Qty;

   -- (c) Add a constraint WITHOUT validating existing rows (faster,
   --     but risky — existing bad data is "grandfathered in")
   -- ALTER TABLE dbo.OnlineSales_Staging WITH NOCHECK
   --     ADD CONSTRAINT CK_Qty2 CHECK (SalesQuantity > 0);

   -- (d) Rename a table or column — T-SQL doesn't use ALTER TABLE
   --     for this; it uses the sp_rename system procedure instead
   --     (unlike MySQL/PostgreSQL, which support ALTER TABLE ... RENAME):
   -- EXEC sp_rename 'dbo.OnlineSales_Staging.Currency', 'CurrencyCode', 'COLUMN';
   -- EXEC sp_rename 'dbo.OnlineSales_Staging', 'OnlineSales_Staging_Old';

   -- (e) Disable/re-enable an existing constraint temporarily
   --     (useful during bulk loads)
   -- ALTER TABLE dbo.OnlineSales_Staging NOCHECK CONSTRAINT DF_Currency;
   -- ALTER TABLE dbo.OnlineSales_Staging  CHECK CONSTRAINT DF_Currency;
   ---------------------------------------------------------------- */


/* ================================================================
   ## 2.3 TRUNCATE TABLE vs DROP TABLE vs DELETE
   ================================================================
   TRUNCATE removes ALL rows fast (resets identity), keeps the
   table structure. It cannot be filtered with WHERE.

              | DELETE          | TRUNCATE           | DROP
   -----------|-----------------|---------------------|------------------
   Filter?    | WHERE allowed   | whole table only    | n/a (whole table)
   Structure  | kept            | kept                | destroyed
   Identity   | not reset       | reset to seed       | n/a
   Logging    | fully logged    | minimally logged    | minimally logged
   Speed      | slower on many  | fast                | fast
              | rows
   Rollback?  | yes, always     | yes, if inside an    | yes, if inside an
              |                 | explicit transaction | explicit transaction
   Triggers   | fire            | do NOT fire          | n/a
   FK rules   | respected       | table can't be       | table can't be
              |                 | truncated while a    | dropped while
              |                 | FK references it     | referenced by a FK
   ================================================================ */

-- Demo (on the PRACTICE fact table copy, not staging):
SELECT COUNT(*) AS RowsBeforeTruncate FROM dbo.FactOnlineSales_Practice;
GO
TRUNCATE TABLE dbo.FactOnlineSales_Practice;
GO
SELECT COUNT(*) AS RowsAfterTruncate FROM dbo.FactOnlineSales_Practice;
GO

-- Rebuild the practice table for the rest of this file (same as 00_Setup.sql):
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

/* ----------------------------------------------------------------
   Variations:

   -- (a) Drop several tables in a single statement (SQL Server 2016+)
   -- DROP TABLE IF EXISTS dbo.TableA, dbo.TableB, dbo.TableC;

   -- (b) TRUNCATE a table that has a foreign key pointing to it:
   --     not allowed — SQL Server blocks this. You'd need to drop
   --     or disable the FK first, or use DELETE instead.

   -- (c) DELETE with no WHERE removes every row too, but is fully
   --     logged (slower, and can fire DELETE triggers) — prefer
   --     TRUNCATE when you truly want to wipe everything and don't
   --     need row-by-row logging or triggers to fire.
   ---------------------------------------------------------------- */


/* ================================================================
   ## 2.4 Exercises — DDL
   ================================================================ */

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

-- Exercise 2.3: Add a FOREIGN KEY on dbo.Ex_ReturnLog.OnlineSalesKey pointing
-- to dbo.FactOnlineSales_Practice's identity column is not possible (that table
-- has no PK) — so instead, add a UNIQUE constraint on OnlineSalesKey so the same
-- sale can't be logged as returned twice.
-- Write your query below:


-- Solution:
-- ALTER TABLE dbo.Ex_ReturnLog ADD CONSTRAINT UQ_ReturnLog_Sale UNIQUE (OnlineSalesKey);

-- Exercise 2.4: Empty out dbo.FactOnlineSales_Practice completely and as fast
-- as possible, keeping its structure. Which command did you use, and why not DELETE?
-- Write your query below:


-- Solution:
-- TRUNCATE TABLE dbo.FactOnlineSales_Practice;
-- -- TRUNCATE is faster than DELETE for wiping ALL rows because it's minimally
-- -- logged and resets the identity seed, instead of logging each row deletion.
-- -- (Remember to rebuild the practice table afterwards using 00_Setup.sql!)

-- Exercise 2.5: Permanently remove dbo.Ex_ReturnLog from the database.
-- Write your query below:


-- Solution:
-- DROP TABLE IF EXISTS dbo.Ex_ReturnLog;


/* ================================================================
   Continue to 03_DML.sql next.
   ================================================================ */
