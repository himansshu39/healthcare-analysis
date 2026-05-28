-- 05_validation_and_export_queries.sql
-- Useful validation and result-export queries.

USE healthcare_mysql_project;

-- Validate cleaned row count and date range.
SELECT
    COUNT(*) AS cleaned_rows,
    MIN(admission_date) AS first_admission_date,
    MAX(admission_date) AS last_admission_date,
    COUNT(billing_amount) AS valid_billing_records,
    SUM(billing_amount IS NULL) AS invalid_or_negative_billing_records
FROM healthcare_clean;

-- Check possible duplicate remnants after cleaning by all analytic fields except encounter_id.
SELECT
    patient_name, age, gender, blood_type, medical_condition, admission_date, doctor_name,
    hospital, insurance_provider, billing_amount, room_number, admission_type,
    discharge_date, medication, test_results, COUNT(*) AS duplicate_count
FROM healthcare_clean
GROUP BY patient_name, age, gender, blood_type, medical_condition, admission_date, doctor_name,
    hospital, insurance_provider, billing_amount, room_number, admission_type,
    discharge_date, medication, test_results
HAVING COUNT(*) > 1;

-- Export-ready ordered cleaned table.
SELECT *
FROM healthcare_clean
ORDER BY admission_date, encounter_id;

-- Top interpretation table: conditions deviating most from global average billing.
WITH global_stats AS (
    SELECT AVG(billing_amount) AS global_avg_billing
    FROM healthcare_clean
    WHERE billing_amount IS NOT NULL
)
SELECT
    c.medical_condition,
    COUNT(*) AS encounters,
    ROUND(AVG(c.billing_amount), 2) AS avg_billing_amount,
    ROUND(AVG(c.billing_amount) - g.global_avg_billing, 2) AS billing_vs_global_avg,
    ROUND(AVG(c.length_of_stay_days), 2) AS avg_length_of_stay_days,
    ROUND(AVG(c.test_results = 'Abnormal'), 4) AS abnormal_test_rate
FROM healthcare_clean c
CROSS JOIN global_stats g
GROUP BY c.medical_condition, g.global_avg_billing
ORDER BY ABS(billing_vs_global_avg) DESC;
