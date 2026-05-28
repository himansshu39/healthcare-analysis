# Data Dictionary

| Column | Type | Description |
|---|---|---|
| encounter_id | VARCHAR | Synthetic row-level encounter identifier created after deduplication. |
| patient_name | VARCHAR | Patient name from source, cleaned for spacing/case. Excluded from modeling. |
| age | INT | Patient age; invalid values set to NULL. |
| age_group | VARCHAR | Age bucket: Under 18, 18-34, 35-49, 50-64, 65+, or Unknown. |
| gender | VARCHAR | Patient gender category from source. |
| blood_type | VARCHAR | Blood type standardized to uppercase. |
| medical_condition | VARCHAR | Main condition category. |
| admission_date | DATE | Date of admission. |
| admission_year | INT | Year extracted from admission date. |
| admission_month | DATE/VARCHAR | First day of admission month for time-series grouping. |
| doctor_name | VARCHAR | Doctor name from source. Excluded from modeling by default. |
| hospital | VARCHAR | Hospital name from source. Excluded from generalizable modeling by default. |
| insurance_provider | VARCHAR | Insurance provider category. |
| billing_amount | DECIMAL | Billing amount. Negative source values are set to NULL. |
| billing_amount_issue | VARCHAR | Data-quality flag for invalid billing values. |
| room_number | INT | Room number from source. Excluded from modeling by default. |
| admission_type | VARCHAR | Elective, Emergency, or Urgent. |
| discharge_date | DATE | Discharge date. |
| length_of_stay_days | INT | Difference between discharge and admission date. Negative values set to NULL. |
| length_of_stay_bucket | VARCHAR | Length-of-stay bucket for SQL grouping models. |
| medication | VARCHAR | Medication category. |
| test_results | VARCHAR | Test result category; used as a classification target. |
