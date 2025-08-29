-- ===========================================
-- DATA CLEANING PROJECT: WORLD LAYOFFS DATA
-- ===========================================

-- 1️⃣ Create table based on CSV columns
CREATE TABLE IF NOT EXISTS layoffs (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INTEGER,
    percentage_laid_off TEXT,  -- kept as TEXT because CSV may have "25%" or NULL
    date DATE,
    stage TEXT,
    country TEXT,
    funds_raised_millions NUMERIC
);

-- Connect to database from terminal:
-- psql -U postgres -d world_layoffs

-- 2️⃣ Import CSV using \copy (client-side)
-- NULL 'NULL' converts string "NULL" into actual NULL
-- \copy layoffs FROM '/Users/user/Downloads/layoffs.csv' DELIMITER ',' CSV HEADER NULL 'NULL';

-- Quick check: see first 10 rows
SELECT * FROM layoffs LIMIT 100;

-- ===========================================
-- 3️⃣ Remove exact duplicate rows
CREATE TABLE layoffs_clean AS
SELECT DISTINCT ON (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)
       *
FROM layoffs
ORDER BY company, location, industry, total_laid_off, date;

-- Check duplicates removed
SELECT COUNT(*) AS total_rows_clean FROM layoffs_clean;

-- ===========================================
-- 4️⃣ Standardize text columns
-- Trim whitespace from start/end
UPDATE layoffs_clean
SET company = TRIM(company),
    location = TRIM(location),
    industry = TRIM(industry),
    stage = TRIM(stage),
    country = TRIM(country);

-- Check trimming
SELECT company, location, industry, stage, country
FROM layoffs_clean
LIMIT 1000;

-- Standardize industry names (example: change CryptoCurrency to Crypto)
UPDATE layoffs_clean
SET industry = 'Crypto'
WHERE industry IN ('CryptoCurrency', 'Crypto Currency');

-- Check industry standardization
SELECT DISTINCT industry FROM layoffs_clean;

-- Standardize country names (remove trailing dots)
UPDATE layoffs_clean
SET country = TRIM(TRAILING '.' FROM country);

-- Check country standardization
SELECT DISTINCT country FROM layoffs_clean;


Select * 
from layoffs

-- ===========================================
-- 5️⃣ Fill missing industries based on company
UPDATE layoffs_clean AS w1
SET industry = w2.industry
FROM layoffs_clean AS w2
WHERE w1.company = w2.company
  AND w1.industry IS NULL
  AND w2.industry IS NOT NULL;

-- Check missing industries filled
SELECT * FROM layoffs_clean WHERE industry IS NULL;

-- Check if this row still has NULL industry
SELECT * 
FROM layoffs_clean 
WHERE company = 'Bally''s Interactive';

-- update it 
UPDATE layoffs_clean
SET industry = 'Unknown'
WHERE company = 'Bally''s Interactive'
  AND industry IS NULL;


--- Replace NULLs in numeric columns with 0, This ensures calculations like SUM or AVG don’t break or return NULL.
UPDATE layoffs_clean
SET total_laid_off = 0
WHERE total_laid_off IS NULL;

UPDATE layoffs_clean
SET funds_raised_millions = 0
WHERE funds_raised_millions IS NULL;

--- Replace NULLs in categorical/text columns
UPDATE layoffs_clean
SET industry = 'Unknown'
WHERE industry IS NULL;

UPDATE layoffs_clean
SET stage = 'Unknown'
WHERE stage IS NULL;

--- verify the changes made
SELECT *
FROM layoffs_clean
WHERE company = 'Bally''s Interactive';

------
SELECT * 
FROM layoffs_clean

-- ===========================================
-- 6️⃣ Handle dates
-- it seems like the date format is year-month-day so i have Converted to DD-MM-YYYY
SELECT TO_CHAR(date, 'DD-MM-YYYY') AS formatted_date
FROM layoffs_clean
LIMIT 10;

-- Check date conversion
SELECT date FROM layoffs_clean LIMIT 10;

--- overwrite the column as text in DD-MM-YYYY format
-- Add a new text column to store formatted date
ALTER TABLE layoffs_clean
ADD COLUMN date_formatted TEXT;

-- Fill the new column with day-month-year format
UPDATE layoffs_clean
SET date_formatted = TO_CHAR(date, 'DD-MM-YYYY');

SELECT * 
FROM layoffs_clean

-- ===========================================
-- 7️⃣ Remove rows where both total_laid_off and percentage_laid_off are NULL
DELETE FROM layoffs_clean
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Check how many rows remain
SELECT COUNT(*) AS total_rows_cleaned FROM layoffs_clean;

SELECT * 
FROM layoffs_clean


-- ===========================================
-- 9️⃣ Quick analysis / exploration
-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Total layoffs by country
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean
GROUP BY country
ORDER BY total_laid_off DESC;

-----------------------------------------
-----------------------------------------
-- Top 10 companies with largest layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 100;

---seem to return total_laid_off with null so i have fixed by treating missing values as zero, using 'COALESCE'

SELECT 
    company, 
    SUM(COALESCE(total_laid_off, 0)) AS total_laid_off
FROM layoffs_clean
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 100;

--COALESCE(total_laid_off, 0) replaces any NULL in total_laid_off with 0 before summing
-- his ensures that even companies where total_laid_off was NULL for some or all rows will now show a numeric total instead of NULL

----------------------------------
----------------------------------

-- Count rows per funding stage
SELECT stage, COUNT(*) AS num_companies
FROM layoffs_clean
GROUP BY stage
ORDER BY num_companies DESC;


SELECT * 
FROM layoffs_clean

-- ===========================================
-- At this point, layoffs_clean table is ready for analysis
-- It has duplicates removed and text standardized
-- invalid rows removed, dates properly formatted, and basic anomaly checks done.
