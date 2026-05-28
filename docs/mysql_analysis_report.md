# Healthcare Dataset: MySQL Cleaning, Exploration, Modeling, and Interpretation

## Executive summary

This project turns a raw healthcare encounter CSV into a MySQL-ready analytics project. The workflow uses a staging table, a cleaned analytic table, SQL exploratory queries, and SQL-only baseline models.

The most important finding is methodological: the available fields are useful for descriptive analysis, but they do **not** contain strong predictive signal for billing or test-result prediction. That is an acceptable and useful portfolio conclusion because it shows baseline comparison and restraint.

## Cleaning results

| Metric | Value |
|---|---:|
| Raw rows | 55,500 |
| Raw columns | 15 |
| Exact duplicate rows removed | 534 |
| Cleaned rows | 54,966 |
| Valid billing records | 54,860 |
| Negative billing values in raw data | 108 |
| Negative billing values after deduplication | 106 |
| Admission date range | 2019-05-08 to 2024-05-07 |
| Average billing amount | $25,594.63 |
| Median billing amount | $25,593.88 |
| Average length of stay | 15.5 days |
| Median length of stay | 15.0 days |

Cleaning rules applied:

1. Removed exact duplicate raw records.
2. Standardized field names to `snake_case`.
3. Parsed dates into ISO/MySQL `DATE` format.
4. Parsed numeric fields: `age`, `room_number`, `billing_amount`, and `length_of_stay_days`.
5. Set negative billing amounts to `NULL`, preserving the issue in `billing_amount_issue`.
6. Added analytic fields: `encounter_id`, `age_group`, `admission_year`, `admission_month`, and `length_of_stay_bucket`.
7. Excluded identifiers such as patient name, doctor, hospital, room number, and encounter ID from modeling.

## Exploratory findings

### Billing and utilization by condition

| Medical condition | Encounters | Avg. billing | Avg. length of stay | Abnormal test rate |
|---|---:|---:|---:|---:|
| Obesity | 9,146 | $25,859.22 | 15.45 | 0.3394 |
| Diabetes | 9,216 | $25,714.33 | 15.43 | 0.3397 |
| Asthma | 9,095 | $25,685.38 | 15.68 | 0.3277 |
| Hypertension | 9,151 | $25,559.84 | 15.44 | 0.3253 |
| Arthritis | 9,218 | $25,542.90 | 15.5 | 0.3424 |
| Cancer | 9,140 | $25,205.92 | 15.5 | 0.338 |

### Overall distributions

- Average age: 51.54 years.
- Average billing amount: $25,594.63.
- Average length of stay: 15.5 days.
- Age-to-billing correlation: -0.0033.
- Length-of-stay-to-billing correlation: -0.0048.

The correlations are near zero, which is a warning that billing amount is not meaningfully explained by the available structured fields.

## SQL-only modeling design

Because standard MySQL does not provide general-purpose machine-learning estimators in the same way Python/scikit-learn does, this project uses transparent SQL baseline models:

1. **Billing regression**
   - Global training-set average.
   - Average billing by medical condition.
   - Grouped average by condition, admission type, insurance provider, age group, and length-of-stay bucket.

2. **Test-result classification**
   - Global majority class.
   - Grouped majority class by condition, admission type, medication, and age group.

The split is deterministic: `MOD(CRC32(encounter_id), 10) < 8` for train and the remainder for test.

## Model metrics

| Task | Target | Model | Test rows | MAE | RMSE | R² | Accuracy | Macro F1 |
|---|---|---|---:|---:|---:|---:|---:|---:|
| regression | `billing_amount` | `billing_global_mean` | 10884 | 12340.95 | 14242.1 | -0.0 |  |  |
| regression | `billing_amount` | `billing_condition_average` | 10884 | 12338.84 | 14239.57 | 0.0003 |  |  |
| regression | `billing_amount` | `billing_group_average_sql_model` | 10884 | 12472.34 | 14518.03 | -0.0391 |  |  |
| classification | `test_results` | `test_result_global_majority` | 10884 |  |  |  | 0.336 | 0.1677 |
| classification | `test_results` | `test_result_group_majority_sql_model` | 10884 |  |  |  | 0.336 | 0.3358 |

## Interpretation

The billing models fail to materially improve on the global average. The grouped average model has a negative or near-zero R², meaning it explains essentially none of the held-out billing variance. This suggests billing amounts in this dataset are close to randomly distributed relative to condition, admission type, insurance provider, age group, and length of stay.

The test-result classifier is also weak. Accuracy is close to one-third, which is what one expects for a roughly balanced three-class target. The grouped majority classifier does not provide a clinically useful test-result prediction.

## Portfolio framing

Use this project as a SQL analytics project, not as a strong predictive modeling project:

> Built a MySQL healthcare analytics workflow: staged and cleaned 55k encounter records, removed duplicates, handled invalid billing values, created normalized analytic fields, wrote EDA queries, and evaluated SQL-only baseline models. The modeling stage showed that the available fields had weak predictive signal, so the final recommendation emphasized descriptive analytics and better feature collection rather than overstated model performance.

## Recommended next steps

1. Build a Power BI dashboard from `healthcare_clean`.
2. Add realistic predictors if available: procedure codes, diagnosis codes, department, provider specialty, claim line items, severity, and payer contract terms.
3. Use Python or MySQL HeatWave AutoML for richer modeling only after confirming the target has meaningful signal.
4. Keep identifiers out of modeling unless the business goal is hospital/provider-specific benchmarking and privacy controls are explicit.
