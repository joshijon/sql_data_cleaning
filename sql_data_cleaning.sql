-- Step 0: Create staging table and copy data
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

select * from layoffs_staging;

-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

-- 1. Remove Duplicates

# First let's check for duplicates

--  all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate

-- these are our real duplicates 
with duplicate_cte as 
(
 SELECT *,ROW_NUMBER() OVER(
 PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage,
 country, funds_raised_millions) AS row_num
 FROM layoffs_staging
) 
select * 
from duplicate_cte
where row_num > 1; 

-- direct deletion of duplicate rows is not possible as it dosent suppot for cte in mysql. but its possible in sql server ot postgresql

-- now we create a new table with a new column row_number. it displyes the count  on each row that is duplicated. 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_staging2;

insert into layoffs_staging2
SELECT *,ROW_NUMBER() OVER(
 PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage,
 country, funds_raised_millions) AS row_num
 from layoffs_staging;
 
 select * from layoffs_staging2;
 
 select * from layoffs_staging2 where row_num >= 2;
 -- these are the ones we want to delete where the row number is > 1 or 2or greater essentially
 
 SET SQL_SAFE_UPDATES = 0; 

 delete from layoffs_staging2 where row_num >= 2;
 

-- Standardizing data
select * from 
layoffs_staging2;

-- trimming whitespaces
update layoffs_staging2
set company= trim(company),location = trim(location), industry = trim(industry),country = trim(country) ;

select distinct(industry) from 
layoffs_staging2
order by 1;

select distinct(industry)  from
layoffs_staging2
where industry like 'crypto%'
order by 1;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

select distinct(location) from 
layoffs_staging2
order by 1;

-- looks fine. i still doubt one city is incorrect. my assumption is dusseldorf

select distinct(country) from 
layoffs_staging2
order by 1;

-- there is 'one period' after united states

select distinct(country), trim(trailing '.' from country)
 from layoffs_staging2
where country like 'United States%';

update layoffs_staging2
set country  = trim(trailing '.' from country)
where country like 'United States%';

select * from 
layoffs_staging2;

-- data type for data is text. we need to change to datatype 'date'
-- Accurate comparisons – Use >, <, BETWEEN, etc. reliably.
-- Proper sorting – Chronological order works as expected.
-- Use date functions – Extract year, month, calculate intervals (DATEDIFF, YEAR(), etc.).
-- Data validation – Prevents invalid date entries.



update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- still the data type is text. we have to change it into data

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- dealing with null vlaues

select distinct(industry)
from layoffs_staging2;

-- here we can see null values and blank values. lets look deep

select * from layoffs_staging2
where industry is null or industry = '';

-- here we can see missig values. theres is possibily to populate those missing values once we know the real value.
-- taking an example with Airbnb

select * from layoffs_staging2
where company like 'Airbnb%';

-- now we undertand industry of airbnb is travel from other rows.
-- there are similar possibilities with other companies tooo
-- lets do self joining
update layoffs_staging2
set industry = null 
where industry = ''; -- helps to give less complicated conditions in join

select t1.industry, t2.industry
from layoffs_staging2 t1 
join layoffs_staging2 t2
   on t1.company = t2.company
where t1.industry is null and t2.industry is not null;

update layoffs_staging2 t1 
join layoffs_staging2 t2
   on t1.company = t2.company
   and t1.location = t2.location -- assuming there is possibilty for same name with different industry in another location
   set t1.industry = t2.industry
where t1.industry is null and t2.industry is not null;


-- Removing unwanted rows and columns



select * from layoffs_staging2
where total_laid_off is null;


select * from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

-- here there are certain rows in which both total_laid_off and percentage_laid_off have nulls values
-- it seems to be useless since we dont have any attributes to analyse
-- so lets delete such rows

delete 
from layoffs_staging2
where total_laid_off is null 
and percentage_laid_off is null;

-- column row_num is not required anymore

alter table layoffs_staging2
drop column row_num;





 
 
 

