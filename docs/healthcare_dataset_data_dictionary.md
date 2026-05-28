# Healthcare Dataset Data Dictionary

| Field | Type | Description |
|---|---|---|
| encounter_id | text | Stable synthetic encounter identifier assigned after exact duplicate removal. |
| patient_name | text | Patient name standardized to readable title case. |
| age | integer | Patient age in years. |
| age_group | category | Age bucket: Under 18, 18-34, 35-49, 50-64, 65-79, or 80+. |
| gender | category | Patient gender as provided in the source, standardized for casing. |
| blood_type | category | Patient blood type. |
| medical_condition | category | Primary medical condition listed for the encounter. |
| date_of_admission | date | Admission date in ISO YYYY-MM-DD format. |
| admission_year | integer | Calendar year extracted from date_of_admission. |
| admission_month | text | Calendar month extracted from date_of_admission in YYYY-MM format. |
| doctor | text | Attending doctor name standardized to readable title case. |
| hospital | text | Hospital name standardized to readable title case; stray trailing punctuation removed. |
| insurance_provider | category | Insurance provider listed for the encounter. |
| billing_amount | decimal | Valid billing amount rounded to two decimals; blank when source billing was negative. |
| billing_amount_issue | category/text | Blank for valid billing amounts; `negative_original_value` when source billing was negative. |
| room_number | integer | Room number. |
| admission_type | category | Emergency, Urgent, or Elective. |
| discharge_date | date | Discharge date in ISO YYYY-MM-DD format. |
| length_of_stay_days | integer | Discharge date minus admission date, in days. |
| medication | category | Medication listed for the encounter. |
| test_results | category | Test-result status listed for the encounter. |
