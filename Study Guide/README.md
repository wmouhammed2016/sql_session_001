# SQL-S8 Study Guide (Multi-Part)

This replaces the single `study_guide_001.sql` file with a numbered series that's easier to work through one topic at a time. Run the files **in order** — each part assumes `00_Setup.sql` has been run first in that session, since it creates the `dbo.FactOnlineSales_Practice` table every other part writes to.

| # | File | Topic | Lecture Agenda section |
|---|------|-------|-------------------------|
| 00 | `00_Setup.sql` | Practice table setup (+ other ways to seed a table) | — |
| 01 | `01_Database_Concepts.sql` | DBMS, schema, transactions (with a real `BEGIN/COMMIT/ROLLBACK` demo) | 1. Database & SQL Foundations |
| 02 | `02_DDL.sql` | `CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`, `TRUNCATE TABLE` | 2. DDL — Defining the Database Structure |
| 03 | `03_DML.sql` | `SELECT DISTINCT`, `INSERT INTO`, `UPDATE`, `DELETE`, DDL vs DML recap | 3. DML — Reading and Changing Data |
| 04 | `04_WHERE_Filtering.sql` | Comparison operators, `AND`/`OR`/`NOT`, `IN`, `BETWEEN`, `LIKE` | 4. WHERE — Filtering Rows |
| 05 | `05_Aggregate_Functions.sql` | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` | 5. Aggregation — Summarizing Data |
| 06 | `06_GROUP_BY_HAVING.sql` | `GROUP BY`, `HAVING`, `ROLLUP`/`CUBE`/`GROUPING SETS` | 5. Aggregation — Summarizing Data |
| 07 | `07_DISTINCT_and_NULLs.sql` | `COUNT(DISTINCT ...)`, NULL handling (`ISNULL`, `COALESCE`, `NULLIF`) | 5. Aggregation — Summarizing Data |
| 08 | `08_Final_Review.sql` | Mixed exercises combining every part above | All |

## What's different from the original single file

- **Split into parts** — one focused file per topic instead of one 650-line file, so you can open just the part you're studying.
- **Expanded "Variations" blocks** — after every Demo, a commented block shows other forms of the same statement (e.g. multi-row `INSERT`, `UPDATE ... FROM ... JOIN`, `MERGE`, `ROLLUP`/`CUBE`, `COALESCE` vs `ISNULL`, `EXISTS`/`ANY`/`ALL`, wildcard reference for `LIKE`, and a DELETE/TRUNCATE/DROP comparison table) — these go beyond what the lecture transcripts covered.
- **More exercises** — each part has one or two new exercises on top of the originals, targeting the new variations.
- **A real transaction demo** — Part 1 now runs an actual `BEGIN TRANSACTION ... COMMIT` (previously this was explained but not demonstrated in code).

## How to use each file

- Blocks starting with `## ` are explanations (read them like notes).
- Blocks under **Demo** are runnable code — execute and read the result.
- Blocks under **Variations** are mostly commented-out — read them, and uncomment/run the ones you want to try.
- Blocks under **Exercises** are blank space for you to write your own query; each has a commented-out **Solution** right below it.
