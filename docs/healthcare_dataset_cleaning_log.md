# Healthcare Dataset Cleaning Log

## Files produced

- `healthcare_dataset_cleaned.csv` — cleaned, analysis-ready dataset.
- `healthcare_dataset_cleaned.xlsx` — Excel workbook with cleaned data, QA summary, and data dictionary.
- `healthcare_dataset_data_dictionary.md` — field definitions.
- `healthcare_dataset_cleaning_qa.json` — machine-readable QA summary.

## Row and column counts

| Metric | Count |
|---|---:|
| Original rows | 55,500 |
| Original columns | 15 |
| Exact duplicate rows removed | 534 |
| Cleaned rows | 54,966 |
| Cleaned columns | 21 |

## Cleaning decisions

1. Renamed columns to `snake_case` for Python, SQL, and Power BI compatibility.
2. Added `encounter_id` as a stable row identifier after duplicate removal.
3. Standardized patient, doctor, hospital, condition, admission type, medication, and test-result text casing.
4. Trimmed whitespace and removed trailing punctuation from generated hospital names, e.g. names ending in a stray comma.
5. Converted admission and discharge dates to ISO `YYYY-MM-DD` strings.
6. Added `admission_year`, `admission_month`, `age_group`, and `length_of_stay_days` to make analysis easier.
7. Rounded valid `billing_amount` values to two decimals.
8. Treated negative billing amounts as invalid ordinary charge values. These were set blank in `billing_amount` and marked with `billing_amount_issue = negative_original_value`.
9. Removed exact duplicate records. No fuzzy duplicate matching was performed because the dataset lacks a true patient identifier.

## Quality checks

| Check | Result |
|---|---:|
| Missing values in original file | 0 |
| Negative billing amounts in original file | 108 |
| Negative billing amounts after duplicate removal, set blank | 106 |
| Invalid ages after cleaning | 0 |
| Negative length-of-stay values after cleaning | 0 |
| Original hospital names ending in trailing punctuation | 4,776 |

## Clean numeric ranges

| Field | Min | Max | Mean |
|---|---:|---:|---:|
| Age | 13 | 89 | 51.54 |
| Billing amount, valid only | $9.24 | $52,764.28 | $25,594.63 |
| Length of stay, days | 1 | 30 | 15.50 |
