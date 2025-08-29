

````markdown
# World Layoffs Data Cleaning

## Description
Data cleaning project for the World Layoffs dataset using PostgreSQL. Includes table creation, CSV import, duplicate removal, standardizing text, handling NULLs, date formatting, anomaly checks, and basic exploratory analysis. Fully commented for clarity.

## Dataset
The dataset contains global company layoffs, with columns:
- `company`
- `location`
- `industry`
- `total_laid_off`
- `percentage_laid_off`
- `date`
- `stage`
- `country`
- `funds_raised_millions`

## Setup
1. Install PostgreSQL: [https://www.postgresql.org/download/](https://www.postgresql.org/download/)
2. Create a database:
   ```sql
   CREATE DATABASE world_layoffs;
````

3. Connect to the database:

   ```bash
   psql -U postgres -d world_layoffs
   ```
4. Create table and import CSV:

   ```sql
   \copy layoffs FROM '/path/to/layoffs.csv' DELIMITER ',' CSV HEADER NULL 'NULL';
   ```

## Data Cleaning Steps

1. Remove duplicates
2. Standardize text fields (company, industry, country, stage)
3. Handle NULL values in numeric and categorical columns
4. Convert date formats
5. Flag anomalies (negative layoffs or funds)
6. Basic exploratory queries (total layoffs by industry, country, top companies, funding stage counts)

## Sample Queries

```sql
-- Check top 10 companies by layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean
GROUP BY industry
ORDER BY total_laid_off DESC;
```

## Notes
All SQL scripts are fully commented for clarity.
Ensure CSV paths are updated according to your local system.
This project prepares data for further analysis or visualization.

