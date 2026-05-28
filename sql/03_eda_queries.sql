-- 03_eda_queries.sql
-- Exploratory analysis queries for healthcare_clean.

USE healthcare_mysql_project;

-- Row-count and cleaning QA.
SELECT
    (SELECT COUNT(*) FROM raw_healthcare) AS raw_rows,
    (SELECT COUNT(*) FROM healthcare_clean) AS cleaned_rows,
    (SELECT COUNT(*) FROM raw_healthcare) - (SELECT COUNT(*) FROM healthcare_clean) AS exact_duplicates_removed,
    SUM(billing_amount_issue = 'negative_original_value') AS negative_billing_rows_after_dedup,
    SUM(age IS NULL) AS invalid_age_rows,
    SUM(length_of_stay_days IS NULL) AS invalid_los_rows
FROM healthcare_clean;

-- Overall numeric profile.
SELECT
    COUNT(*) AS encounters,
    COUNT(billing_amount) AS valid_billing_records,
    ROUND(AVG(age), 2) AS avg_age,
    MIN(age) AS min_age,
    MAX(age) AS max_age,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(MIN(billing_amount), 2) AS min_billing_amount,
    ROUND(MAX(billing_amount), 2) AS max_billing_amount,
    ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay_days,
    MIN(admission_date) AS first_admission_date,
    MAX(admission_date) AS last_admission_date
FROM healthcare_clean;

-- Billing and utilization by condition.
SELECT
    medical_condition,
    COUNT(*) AS encounters,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay_days,
    ROUND(AVG(test_results = 'Abnormal'), 4) AS abnormal_test_rate
FROM healthcare_clean
GROUP BY medical_condition
ORDER BY avg_billing_amount DESC;

-- Billing and utilization by admission type.
SELECT
    admission_type,
    COUNT(*) AS encounters,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay_days
FROM healthcare_clean
GROUP BY admission_type
ORDER BY avg_billing_amount DESC;

-- Insurance provider comparison.
SELECT
    insurance_provider,
    COUNT(*) AS encounters,
    ROUND(AVG(billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(length_of_stay_days), 2) AS avg_length_of_stay_days
FROM healthcare_clean
GROUP BY insurance_provider
ORDER BY avg_billing_amount DESC;

-- Monthly admission trend.
SELECT
    admission_month,
    COUNT(*) AS admissions
FROM healthcare_clean
GROUP BY admission_month
ORDER BY admission_month;

-- Test-result distribution.
SELECT
    test_results,
    COUNT(*) AS encounters,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM healthcare_clean), 4) AS pct_of_rows
FROM healthcare_clean
GROUP BY test_results
ORDER BY encounters DESC;

-- Pearson-style correlations in SQL.
SELECT
    ROUND(
        (COUNT(*) * SUM(age * billing_amount) - SUM(age) * SUM(billing_amount)) /
        SQRT((COUNT(*) * SUM(age * age) - POW(SUM(age), 2)) *
             (COUNT(*) * SUM(billing_amount * billing_amount) - POW(SUM(billing_amount), 2))), 4
    ) AS corr_age_billing,
    ROUND(
        (COUNT(*) * SUM(length_of_stay_days * billing_amount) - SUM(length_of_stay_days) * SUM(billing_amount)) /
        SQRT((COUNT(*) * SUM(length_of_stay_days * length_of_stay_days) - POW(SUM(length_of_stay_days), 2)) *
             (COUNT(*) * SUM(billing_amount * billing_amount) - POW(SUM(billing_amount), 2))), 4
    ) AS corr_los_billing
FROM healthcare_clean
WHERE billing_amount IS NOT NULL
  AND age IS NOT NULL
  AND length_of_stay_days IS NOT NULL;
