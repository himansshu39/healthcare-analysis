-- 02_clean_transform.sql
-- Creates a cleaned analytic table from raw_healthcare.
-- Requires MySQL 8.0+ for ROW_NUMBER and REGEXP_REPLACE.

USE healthcare_mysql_project;

DROP TABLE IF EXISTS healthcare_clean;

CREATE TABLE healthcare_clean AS
WITH raw_normalized AS (
    SELECT
        raw_row_id,
        TRIM(REGEXP_REPLACE(name_raw, '[[:space:]]+', ' ')) AS patient_name,
        CAST(NULLIF(TRIM(age_raw), '') AS UNSIGNED) AS age,
        CASE
            WHEN LOWER(TRIM(gender_raw)) = 'male' THEN 'Male'
            WHEN LOWER(TRIM(gender_raw)) = 'female' THEN 'Female'
            ELSE TRIM(gender_raw)
        END AS gender,
        UPPER(TRIM(blood_type_raw)) AS blood_type,
        TRIM(medical_condition_raw) AS medical_condition,
        STR_TO_DATE(TRIM(date_of_admission_raw), '%Y-%m-%d') AS admission_date,
        TRIM(REGEXP_REPLACE(doctor_raw, '[[:space:]]+', ' ')) AS doctor_name,
        TRIM(REGEXP_REPLACE(hospital_raw, '[[:space:]]+', ' ')) AS hospital,
        TRIM(insurance_provider_raw) AS insurance_provider,
        CAST(NULLIF(TRIM(billing_amount_raw), '') AS DECIMAL(12,2)) AS billing_amount_original,
        CAST(NULLIF(TRIM(room_number_raw), '') AS UNSIGNED) AS room_number,
        TRIM(admission_type_raw) AS admission_type,
        STR_TO_DATE(TRIM(discharge_date_raw), '%Y-%m-%d') AS discharge_date,
        TRIM(medication_raw) AS medication,
        TRIM(test_results_raw) AS test_results,
        ROW_NUMBER() OVER (
            PARTITION BY name_raw, age_raw, gender_raw, blood_type_raw, medical_condition_raw,
                         date_of_admission_raw, doctor_raw, hospital_raw, insurance_provider_raw,
                         billing_amount_raw, room_number_raw, admission_type_raw, discharge_date_raw,
                         medication_raw, test_results_raw
            ORDER BY raw_row_id
        ) AS duplicate_row_number
    FROM raw_healthcare
), deduped AS (
    SELECT *
    FROM raw_normalized
    WHERE duplicate_row_number = 1
), cleaned_pre AS (
    SELECT
        raw_row_id,
        patient_name,
        CASE WHEN age BETWEEN 0 AND 120 THEN age ELSE NULL END AS age,
        CASE
            WHEN age IS NULL THEN 'Unknown'
            WHEN age < 18 THEN 'Under 18'
            WHEN age BETWEEN 18 AND 34 THEN '18-34'
            WHEN age BETWEEN 35 AND 49 THEN '35-49'
            WHEN age BETWEEN 50 AND 64 THEN '50-64'
            ELSE '65+'
        END AS age_group,
        gender,
        blood_type,
        medical_condition,
        admission_date,
        YEAR(admission_date) AS admission_year,
        DATE_FORMAT(admission_date, '%Y-%m-01') AS admission_month,
        doctor_name,
        hospital,
        insurance_provider,
        CASE WHEN billing_amount_original < 0 THEN NULL ELSE billing_amount_original END AS billing_amount,
        CASE
            WHEN billing_amount_original < 0 THEN 'negative_original_value'
            WHEN billing_amount_original IS NULL THEN 'invalid_original_value'
            ELSE NULL
        END AS billing_amount_issue,
        room_number,
        admission_type,
        discharge_date,
        CASE
            WHEN discharge_date >= admission_date THEN DATEDIFF(discharge_date, admission_date)
            ELSE NULL
        END AS length_of_stay_days,
        medication,
        test_results
    FROM deduped
)
SELECT
    CONCAT('ENC', LPAD(ROW_NUMBER() OVER (ORDER BY raw_row_id), 6, '0')) AS encounter_id,
    patient_name,
    age,
    age_group,
    gender,
    blood_type,
    medical_condition,
    admission_date,
    admission_year,
    admission_month,
    doctor_name,
    hospital,
    insurance_provider,
    billing_amount,
    billing_amount_issue,
    room_number,
    admission_type,
    discharge_date,
    length_of_stay_days,
    CASE
        WHEN length_of_stay_days IS NULL THEN 'Unknown'
        WHEN length_of_stay_days <= 3 THEN '0-3 days'
        WHEN length_of_stay_days <= 7 THEN '4-7 days'
        WHEN length_of_stay_days <= 14 THEN '8-14 days'
        WHEN length_of_stay_days <= 21 THEN '15-21 days'
        WHEN length_of_stay_days <= 30 THEN '22-30 days'
        ELSE '31+ days'
    END AS length_of_stay_bucket,
    medication,
    test_results
FROM cleaned_pre;

ALTER TABLE healthcare_clean ADD PRIMARY KEY (encounter_id);
CREATE INDEX ix_healthcare_condition ON healthcare_clean (medical_condition);
CREATE INDEX ix_healthcare_admission_date ON healthcare_clean (admission_date);
CREATE INDEX ix_healthcare_insurance ON healthcare_clean (insurance_provider);
CREATE INDEX ix_healthcare_admission_type ON healthcare_clean (admission_type);
CREATE INDEX ix_healthcare_test_results ON healthcare_clean (test_results);

SELECT COUNT(*) AS cleaned_rows FROM healthcare_clean;
