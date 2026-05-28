-- 01_create_and_load.sql
-- MySQL 8.0+ / MySQL Workbench
-- Replace the LOCAL INFILE path with the absolute path to your raw CSV.

CREATE DATABASE IF NOT EXISTS healthcare_mysql_project;
USE healthcare_mysql_project;

DROP TABLE IF EXISTS raw_healthcare;
CREATE TABLE raw_healthcare (
    raw_row_id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name_raw VARCHAR(255),
    age_raw VARCHAR(20),
    gender_raw VARCHAR(50),
    blood_type_raw VARCHAR(10),
    medical_condition_raw VARCHAR(100),
    date_of_admission_raw VARCHAR(30),
    doctor_raw VARCHAR(255),
    hospital_raw VARCHAR(255),
    insurance_provider_raw VARCHAR(100),
    billing_amount_raw VARCHAR(50),
    room_number_raw VARCHAR(30),
    admission_type_raw VARCHAR(100),
    discharge_date_raw VARCHAR(30),
    medication_raw VARCHAR(100),
    test_results_raw VARCHAR(100)
);

-- Before running LOAD DATA, you may need:
-- SET GLOBAL local_infile = 1;
-- Then enable OPT_LOCAL_INFILE in your MySQL Workbench connection settings.

LOAD DATA LOCAL INFILE '/absolute/path/to/healthcare_dataset.csv'
INTO TABLE raw_healthcare
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(name_raw, age_raw, gender_raw, blood_type_raw, medical_condition_raw,
 date_of_admission_raw, doctor_raw, hospital_raw, insurance_provider_raw,
 billing_amount_raw, room_number_raw, admission_type_raw, discharge_date_raw,
 medication_raw, test_results_raw);

SELECT COUNT(*) AS raw_rows_loaded FROM raw_healthcare;
