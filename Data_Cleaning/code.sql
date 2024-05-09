-- Data Cleaning

SELECT * FROM layoffs;

-- 1) Remove Duplicates
-- 2) Standardizing the Data
-- 3) Null Values or blank values
-- 4) Remove any columns
 
-- REMOVE DUPLICATES

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
industry, total_laid_off,percentage_laid_off,'date',
stage, country, funds_raised_millions);


-- Creating duplicate_cte to chcek the duplicates using row_number()
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
industry, total_laid_off,percentage_laid_off,'date',
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoffs_staging
WHERE company='Casper';

-- Delete statement cannot work here.
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
industry, total_laid_off,percentage_laid_off,'date',
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- Creating another table 'layoffs_staging2', but with row_num column to delete the duplicate values


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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT * 
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,location,
industry, total_laid_off,percentage_laid_off,'date',
stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT * 
FROM layoffs_staging2
WHERE row_num>1;

-- Deleting Duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;
 
 -- Duplicates Deleted!!
SELECT * 
FROM layoffs_staging2;


-- STANDARDIZING THE DATA

SELECT company,TRIM(company)
FROM layoffs_staging2;
 
UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT company
FROM layoffs_staging2;



SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE "Crypto%";


SELECT *
FROM layoffs_staging2
WHERE country LIKE "United States%"
ORDER BY 1;

SELECT * 
FROM layoffs_staging2
WHERE country="United States.";

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE "United States.";


SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date`  DATE;

DESCRIBE layoffs_staging2;

-- DEAL WITH NULL AND BLANK VALUES

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry='';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *       -- t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry=NULL
WHERE industry='';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company = "Bally's Interactive";

SELECT * 
FROM layoffs_staging2;

-- REMOVE ANY COLUMNS OR ROWS

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- FINAL CLEANED DATA!!!!

SELECT *
FROM layoffs_staging2;
