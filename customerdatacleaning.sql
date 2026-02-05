USE customer_data;
SELECT * FROM retailcustomers;
-- THE COMPLETE INTEGRATED CLEANING PIPELINE (FINAL VERSION)
WITH 
-- STEP 1: INITIAL STANDARDIZATION & OUTLIER DETECTION
step1_standardize AS (
    SELECT
        customer_id,
        TRIM(CONCAT(UPPER(LEFT(first_name, 1)), LOWER(SUBSTRING(first_name, 2)))) AS first_name,
        TRIM(CONCAT(UPPER(LEFT(last_name, 1)), LOWER(SUBSTRING(last_name, 2)))) AS last_name,
        LOWER(REPLACE(email, ' ', '')) AS email,
        -- Phone Standardization Logic (+27 format)
        CASE 
            WHEN phone_number IS NULL OR TRIM(phone_number) = '' THEN 'Not Provided'
            WHEN phone_number LIKE '27%' THEN CONCAT('+', phone_number)
            WHEN phone_number LIKE '0%'  THEN CONCAT('+27', SUBSTRING(phone_number, 2))
            WHEN phone_number LIKE '+27%' THEN phone_number
            ELSE 'Not Provided' 
        END AS phone_number,
        CASE 
            WHEN city IS NULL OR TRIM(city) = '' THEN 'Unknown'
            ELSE TRIM(CONCAT(UPPER(LEFT(city, 1)), LOWER(SUBSTRING(city, 2))))
        END AS city,
        -- Age Outlier Logic: Catch NULL, Empty, and ages < 0 or > 100
        CASE 
            WHEN age IS NULL OR CAST(age AS CHAR) = '' THEN 'Not Provided' 
            WHEN age <= 0 OR age > 100 THEN 'Not Provided' -- Outlier Handling
            ELSE CAST(age AS CHAR) 
        END AS age_string,
        -- Date Parsing logic
        CASE 
            WHEN registration_date IS NULL OR TRIM(registration_date) = '' THEN NULL
            WHEN registration_date LIKE '%_%, 20%' THEN STR_TO_DATE(registration_date, '%b %d, %Y')
            WHEN registration_date LIKE '%/%/%' THEN STR_TO_DATE(registration_date, '%d/%m/%Y')
            WHEN registration_date LIKE '20%-%-%' THEN CAST(registration_date AS DATE)
            ELSE NULL 
        END AS cleaned_date_obj
    FROM retailcustomers
),

-- STEP 2: DEDUPLICATION & EMAIL VALIDATION
step2_deduplicate AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY cleaned_date_obj DESC) AS row_num
    FROM step1_standardize
    WHERE email LIKE '%@%.%' 
),

-- STEP 3: FINAL ENRICHMENT & LABELING
step3_final_clean AS (
    SELECT
        customer_id,
        CONCAT(first_name, ' ', last_name) AS full_name,
        email,
        phone_number,
        city,
        age_string AS age,
        CASE 
            WHEN cleaned_date_obj IS NULL THEN 'Unknown' 
            ELSE CAST(cleaned_date_obj AS CHAR) 
        END AS registration_date,
        CASE 
            WHEN cleaned_date_obj IS NULL THEN '-' 
            ELSE CAST(DATEDIFF(CURRENT_DATE, cleaned_date_obj) AS CHAR) 
        END AS days_since_registration,
        -- Quality Flag (Now includes Outlier detection)
        CASE
            WHEN phone_number = 'Not Provided' 
                 OR city = 'Unknown' 
                 OR age_string = 'Not Provided' 
                 OR cleaned_date_obj IS NULL THEN 'Incomplete'
            ELSE 'Complete'
        END AS data_quality_flag
    FROM step2_deduplicate
    WHERE row_num = 1
)

-- FINAL OUTCOME
SELECT * FROM step3_final_clean;