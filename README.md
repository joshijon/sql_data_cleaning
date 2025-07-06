
# 🧹 SQL Data Cleaning Project – Layoffs Dataset (MySQL)

This project demonstrates a complete SQL-based data cleaning workflow using **MySQL** on a dataset of company layoffs. The goal is to prepare the data for accurate analysis by removing duplicates, standardizing inconsistent entries, handling null values, and optimizing data types.

---

- **SQL Concepts**:
  - CTEs and `ROW_NUMBER()`
  - `TRIM`, `STR_TO_DATE`, `ALTER TABLE`
  - `JOIN` operations for data enrichment
  - NULL handling and outlier removal

---

## Cleaning Steps

### 1. Create a Staging Table
- Copied raw data to a staging table (`layoffs_staging`)
- Created a second staging table with `ROW_NUMBER()` logic for deduplication

### 2. Remove Duplicates
- Used window functions to identify duplicates
- Deleted rows where `row_num > 1`

### 3. Standardize and Correct Data
- Trimmed whitespace from text fields
- Normalized values (e.g., `crypto` → `Crypto`)
- Fixed formatting issues in country names (`United States.` → `United States`)

### 4. Convert Data Types
- Converted the `date` column from `TEXT` to `DATE` using `STR_TO_DATE` and `ALTER TABLE`

### 5. Handle Null and Blank Values
- Replaced blank values with NULLs
- Used self-joins to fill in missing `industry` values based on known company data

### 6. Remove Unnecessary Data
- Deleted rows where both `total_laid_off` and `percentage_laid_off` were NULL
- Dropped the `row_num` column used for duplicate detection

---

## 🧪 Sample Queries

```sql
-- Remove duplicates using row numbers
DELETE FROM layoffs_staging2 WHERE row_num >= 2;

-- Standardize country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date from TEXT to DATE
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
