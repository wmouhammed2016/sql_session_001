/* ================================================================
   SQL-S8 STUDY GUIDE — PART 4: WHERE — FILTERING ROWS
   ================================================================
   Statements/operators covered: comparison operators, AND/OR/NOT,
   IN, BETWEEN, LIKE, plus a preview of EXISTS/ANY/ALL.
   ================================================================ */

USE ContosoRetailDW;
GO


/* ================================================================
   ## 4.1 Comparison operators
   ================================================================ */

-- Demo: sales lines worth more than $500
SELECT OnlineSalesKey, ProductKey, SalesAmount
FROM dbo.FactOnlineSales
WHERE SalesAmount > 500;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) The full set: =, >, <, >=, <=, <> (not equal), != (also
   --     not equal — <> is the ANSI-standard spelling, != works in
   --     T-SQL too but is less portable to other dialects)
   -- SELECT * FROM dbo.FactOnlineSales WHERE StoreKey <> 199;

   -- (b) NULL can't be tested with = or <> — it needs IS NULL /
   --     IS NOT NULL, because NULL means "unknown", and
   --     unknown = anything is also "unknown" (never true).
   -- SELECT * FROM dbo.FactOnlineSales WHERE PromotionKey IS NULL;
   -- SELECT * FROM dbo.FactOnlineSales WHERE PromotionKey IS NOT NULL;
   -- -- WRONG (returns zero rows, always): WHERE PromotionKey = NULL
   ---------------------------------------------------------------- */


/* ================================================================
   ## 4.2 AND / OR / NOT
   ================================================================ */

-- Demo: big-ticket, high-quantity lines that were NOT discounted
SELECT OnlineSalesKey, SalesQuantity, SalesAmount, DiscountAmount
FROM dbo.FactOnlineSales
WHERE SalesAmount > 500
  AND SalesQuantity >= 2
  AND NOT DiscountAmount > 0;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) Operator precedence: NOT binds tighter than AND, which
   --     binds tighter than OR. When mixing AND/OR, use parentheses
   --     to be explicit — don't rely on memorizing the order.
   -- SELECT * FROM dbo.FactOnlineSales
   -- WHERE (StoreKey = 199 OR StoreKey = 306) AND SalesAmount > 100;
   -- -- Without the parentheses, this would be read as:
   -- --   StoreKey = 199 OR (StoreKey = 306 AND SalesAmount > 100)
   -- -- which is a different (and here, wrong) condition.

   -- (b) NOT can wrap a whole condition, not just one column
   -- SELECT * FROM dbo.FactOnlineSales
   -- WHERE NOT (StoreKey = 199 AND SalesAmount > 500);
   ---------------------------------------------------------------- */


/* ================================================================
   ## 4.3 IN
   ================================================================ */

-- Demo: sales from a specific set of stores
SELECT OnlineSalesKey, StoreKey, SalesAmount
FROM dbo.FactOnlineSales
WHERE StoreKey IN (199, 306, 259);
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) NOT IN — the opposite: exclude a list of values
   -- SELECT * FROM dbo.FactOnlineSales WHERE StoreKey NOT IN (199, 306, 259);

   -- (b) IN with a subquery, instead of a hand-typed list — e.g.
   --     "sales from stores in a certain region"
   -- SELECT * FROM dbo.FactOnlineSales
   -- WHERE StoreKey IN (SELECT StoreKey FROM dbo.DimStore WHERE StoreType = 'Store');

   -- (c) *** NOT IN pitfall ***: if the list/subquery can contain a
   --     NULL, NOT IN unexpectedly returns ZERO rows — because
   --     "x <> NULL" is unknown, not true, for every comparison.
   --     Prefer NOT EXISTS (see 4.6) when the subquery might have NULLs.
   -- SELECT * FROM dbo.FactOnlineSales
   -- WHERE StoreKey NOT IN (SELECT StoreKey FROM dbo.DimStore WHERE StoreType IS NULL); -- risky
   ---------------------------------------------------------------- */


/* ================================================================
   ## 4.4 BETWEEN
   ================================================================ */

-- Note: DateKey is a surrogate integer key shaped like YYYYMMDD,
-- not a real DATE column — that's a common data-warehouse pattern.
-- Demo: sales during 2009
SELECT OnlineSalesKey, DateKey, SalesAmount
FROM dbo.FactOnlineSales
WHERE DateKey BETWEEN 20090101 AND 20091231;
GO

/* ----------------------------------------------------------------
   Variations:

   -- (a) BETWEEN is inclusive on both ends (>= low AND <= high)
   -- SELECT * FROM dbo.FactOnlineSales WHERE SalesAmount BETWEEN 100 AND 100; -- matches exactly 100 too

   -- (b) NOT BETWEEN — outside the range
   -- SELECT * FROM dbo.FactOnlineSales WHERE SalesAmount NOT BETWEEN 100 AND 300;

   -- (c) BETWEEN works on real dates too, not just numbers, if you
   --     have an actual DATE/DATETIME column (e.g. on DimDate)
   -- SELECT * FROM dbo.DimDate WHERE FullDateAlternateKey BETWEEN '2009-01-01' AND '2009-12-31';
   ---------------------------------------------------------------- */


/* ================================================================
   ## 4.5 LIKE
   ================================================================ */

-- Demo: order numbers that start with 'SO4'
SELECT DISTINCT SalesOrderNumber
FROM dbo.FactOnlineSales
WHERE SalesOrderNumber LIKE 'SO4%';
GO

/* ----------------------------------------------------------------
   Variations — wildcard reference:

   %      any sequence of characters (including zero)   'SO4%'   -> starts with SO4
   _      exactly one character                          'SO4__1' -> SO4, 2 chars, then 1
   [set]  any one character in the set                    '[SO]%'  -> starts with S or O
   [a-f]  any one character in the range                  '[A-M]%' -> starts with A through M
   [^set] any one character NOT in the set                '[^0-9]%' -> doesn't start with a digit

   -- (a) Contains / ends-with
   -- SELECT DISTINCT SalesOrderNumber FROM dbo.FactOnlineSales WHERE SalesOrderNumber LIKE '%99%';   -- contains "99"
   -- SELECT DISTINCT SalesOrderNumber FROM dbo.FactOnlineSales WHERE SalesOrderNumber LIKE '%001';    -- ends with "001"

   -- (b) Escaping a literal % or _ that's actually part of the data
   -- SELECT * FROM dbo.FactOnlineSales WHERE SalesOrderNumber LIKE '%50\%%' ESCAPE '\';
   -- -- (matches an order number that literally contains "50%")

   -- (c) LIKE is case-sensitive or not depending on the database's
   --     collation setting — ContosoRetailDW's default collation is
   --     typically case-insensitive, so 'so4%' would match 'SO4...' too.
   ---------------------------------------------------------------- */


/* ================================================================
   ## 4.6 BONUS — EXISTS, ANY, ALL (a preview beyond this session)
   ================================================================
   These test against a subquery instead of a fixed list, and are
   worth knowing exist even if we don't drill into them here:

   -- EXISTS — true if the subquery returns at least one row (often
   -- faster than IN, and safe with NULLs)
   -- SELECT * FROM dbo.FactOnlineSales f
   -- WHERE EXISTS (SELECT 1 FROM dbo.DimStore s WHERE s.StoreKey = f.StoreKey AND s.StoreType = 'Store');

   -- ANY / SOME — true if the comparison holds for at least one value returned
   -- SELECT * FROM dbo.FactOnlineSales WHERE SalesAmount > ANY (SELECT SalesAmount FROM dbo.FactOnlineSales WHERE StoreKey = 199);

   -- ALL — true only if the comparison holds for every value returned
   -- SELECT * FROM dbo.FactOnlineSales WHERE SalesAmount > ALL (SELECT SalesAmount FROM dbo.FactOnlineSales WHERE StoreKey = 199);
   ================================================================ */


/* ================================================================
   ## 4.7 Exercises — WHERE
   ================================================================ */

-- Exercise 4.1: Find all sales lines with SalesQuantity greater than 5.
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales WHERE SalesQuantity > 5;

-- Exercise 4.2: Find sales lines where SalesAmount is between 100 and 300
-- AND there was a return (ReturnQuantity > 0).
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales
-- WHERE SalesAmount BETWEEN 100 AND 300
--   AND ReturnQuantity > 0;

-- Exercise 4.3: Find sales lines from store 199 OR store 306 with no discount.
-- Use parentheses correctly.
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales
-- WHERE (StoreKey = 199 OR StoreKey = 306)
--   AND DiscountAmount = 0;

-- Exercise 4.4: Find all distinct SalesOrderNumbers that contain '99' anywhere.
-- Write your query below:


-- Solution:
-- SELECT DISTINCT SalesOrderNumber FROM dbo.FactOnlineSales
-- WHERE SalesOrderNumber LIKE '%99%';

-- Exercise 4.5: Find sales lines whose PromotionKey is missing (NULL).
-- Why won't "PromotionKey = NULL" work here?
-- Write your query below:


-- Solution:
-- SELECT * FROM dbo.FactOnlineSales WHERE PromotionKey IS NULL;
-- -- "=" can't compare against NULL because NULL means "unknown" —
-- -- any comparison against an unknown value is itself unknown, not true.


/* ================================================================
   Continue to 05_Aggregate_Functions.sql next.
   ================================================================ */
