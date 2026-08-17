# SQL-S8 — Combined Lecture Agenda

*Merges the original session agenda with the additional topics covered in the lecture transcripts, arranged in a logical learning order for SQL beginners.*

## 1. Database & SQL Foundations
- What SQL is and how it lets us interact with a relational database (structured intro/orientation)
- Databases, DBMS, and schema — how data is organized
- Relational databases vs. file-based systems, and why relational databases replaced them
- Transactions, and the general limitations of file-based data storage
- DDL vs. DML: the two roles SQL commands play, and where SQL fits into the data analysis workflow

## 2. DDL — Defining the Database Structure
- CREATE TABLE: columns, data types, and constraints (including PRIMARY KEY)
- ALTER TABLE: adding, modifying, and dropping columns
- DROP TABLE: removing a table and its structure entirely
- TRUNCATE TABLE: clearing all rows while keeping the table structure

## 3. DML — Reading and Changing Data
- SELECT and FROM: choosing columns and a source table
- Column aliases, for renaming output columns
- DISTINCT: removing duplicate rows from results
- ORDER BY: sorting results
- TOP: limiting the number of rows returned
- The logical order SQL executes a query in (FROM → WHERE → GROUP BY → HAVING → SELECT/DISTINCT → ORDER BY → TOP)
- INSERT INTO: adding new rows
- UPDATE: modifying existing rows
- DELETE: removing rows

## 4. WHERE — Filtering Rows
- Comparison operators (=, <>, >, <, >=, <=)
- Logical operators: AND, OR, NOT
- IN: matching against a list of values
- BETWEEN: matching a range of values
- LIKE: pattern matching with wildcards

## 5. Aggregation — Summarizing Data
- Aggregate functions: COUNT, SUM, AVG, MIN, MAX
- GROUP BY: combining rows into grouped summaries
- HAVING: filtering on aggregated results
- DISTINCT used inside aggregate functions
- Handling NULL values in aggregations
