/* ================================================================
   SQL-S8 STUDY GUIDE — PART 1: DATABASE CONCEPTS
   Prerequisite: run 00_Setup.sql first (creates the practice table).
   ================================================================ */

USE ContosoRetailDW;
GO

-- select * from factonlinesales_practice
-- order by OnlineSalesKey DESC;
-- -- 19561483
/* ================================================================
   ## 1.1 DBMS, SCHEMA, RELATIONAL DESIGN
   ================================================================
   - DBMS (Database Management System): software that stores,
     organizes, and controls access to data (e.g. SQL Server,
     PostgreSQL, MySQL, Oracle). SQL is the language you use to
     talk to it; the DBMS decides how to actually execute it.
   - Schema: the blueprint of the database — tables, columns, data
     types, and the relationships between them. In SQL Server,
     "schema" also has a narrower meaning: a namespace that groups
     objects together, like "dbo." in front of every table name
     here (dbo = "database owner", the default schema).
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
   ## 1.2 TRANSACTIONS
   ================================================================
   A transaction is one or more statements executed as a single
   unit of work — either ALL of it succeeds (COMMIT) or NONE of it
   does (ROLLBACK). This keeps data consistent even if something
   fails halfway through (e.g. an order INSERT + a matching
   inventory UPDATE).
   ================================================================ */

-- Demo: two related changes wrapped in one transaction.
-- If anything between BEGIN and COMMIT fails, none of it sticks.
SET IDENTITY_INSERT dbo.FactOnlineSales_Practice ON;

BEGIN TRANSACTION;

    INSERT INTO dbo.FactOnlineSales_Practice
        (OnlineSalesKey, DateKey, StoreKey, ProductKey, PromotionKey,
         CurrencyKey, CustomerKey, SalesOrderNumber, SalesOrderLineNumber,
         SalesQuantity, SalesAmount, ReturnQuantity, ReturnAmount,
         DiscountQuantity, DiscountAmount, TotalCost, UnitCost, UnitPrice)
    VALUES
        (19561484, '2026-08-17', 199, 350, 0,
         100, 19998, 'SO999100', 1,
         1, 99.99, 0, 0,
         0, 0, 60.00, 60.00, 99.99);

    UPDATE dbo.FactOnlineSales_Practice
    SET SalesAmount = SalesAmount * 2.0
    WHERE OnlineSalesKey = 19561484;

COMMIT TRANSACTION;
GO

SET IDENTITY_INSERT FactOnlineSales_Practice OFF;

SELECT * FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 19561484;
GO

-- Clean up the demo row.
DELETE FROM dbo.FactOnlineSales_Practice WHERE OnlineSalesKey = 19561484;
GO

/* ----------------------------------------------------------------
   Variations — controlling and inspecting transactions:

   -- (a) Roll back on purpose (e.g. after checking something looks wrong)
   -- BEGIN TRANSACTION;
   --     DELETE FROM dbo.FactOnlineSales_Practice WHERE StoreKey = 199;
   --     -- ...changed your mind, or a check failed...
   -- ROLLBACK TRANSACTION;  -- undoes the DELETE completely

   -- (b) TRY/CATCH pattern — the standard way to roll back on error
   -- BEGIN TRY
   --     BEGIN TRANSACTION;
   --         UPDATE dbo.FactOnlineSales_Practice SET SalesQuantity = SalesQuantity + 1
   --         WHERE OnlineSalesKey = 999100;
   --     COMMIT TRANSACTION;
   -- END TRY
   -- BEGIN CATCH
   --     ROLLBACK TRANSACTION;
   --     PRINT ERROR_MESSAGE();
   -- END CATCH;

   -- (c) SAVE TRANSACTION — a "checkpoint" inside a larger transaction
   --     you can roll back to, without undoing everything before it.
   -- BEGIN TRANSACTION;
   --     UPDATE dbo.FactOnlineSales_Practice SET SalesQuantity = 1 WHERE OnlineSalesKey = 999100;
   --     SAVE TRANSACTION BeforeRiskyStep;
   --     UPDATE dbo.FactOnlineSales_Practice SET SalesQuantity = -1 WHERE OnlineSalesKey = 999100; -- oops
   --     ROLLBACK TRANSACTION BeforeRiskyStep;  -- undoes only the risky step
   -- COMMIT TRANSACTION;

   Further reading (beyond this course): isolation levels
   (READ COMMITTED, READ UNCOMMITTED, REPEATABLE READ, SERIALIZABLE,
   SNAPSHOT) control exactly what one transaction can see of another
   transaction's in-progress changes. SQL Server defaults to
   READ COMMITTED.
   ---------------------------------------------------------------- */


/* ================================================================
   Continue to 02_DDL.sql next.
   ================================================================ */
