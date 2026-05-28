# Healthcare Encounter Analytics

## Project objective

Analyze a healthcare encounter dataset to identify billing, utilization, admission, and test-result patterns. The project includes data cleaning, exploratory analysis, supervised modeling, and interpretation.

## Dataset size

- Rows after cleaning: **54,966**
- Columns after cleaning: **21**
- Admission date range: **2019-05-08 to 2024-05-07**
- Valid billing records: **54,860**

## Business questions

1. How are encounters distributed by medical condition, admission type, payer, and test result?
2. Which conditions have the highest average billing amounts?
3. How does length of stay vary across conditions and admission types?
4. Can available encounter fields predict billing amount?
5. Can available encounter fields predict test-result category?

## Methods

- Standardized and cleaned the dataset.
- Removed exact duplicate rows.
- Flagged and excluded invalid negative billing values from billing analysis.
- Created derived fields for admission year, admission month, age group, and length of stay.
- Built regression models for billing amount.
- Built classification models for test-result category.
- Used model feature importance to interpret behavior.

## Key findings

- Average valid billing amount: **$25,594.63**.
- Median valid billing amount: **$25,593.88**.
- Average length of stay: **15.5 days**.
- Best billing model R²: **-0.0000**.
- Best test-result model macro F1: **0.3153**.

The models did not find strong predictive signal in the available fields. This is useful: the dataset supports data cleaning, EDA, KPI reporting, and modeling workflow demonstration, but it should not be presented as clinically predictive.

## Limitations

- The dataset appears synthetic or highly regularized.
- No stable patient identifier is available.
- Billing values are not strongly explained by available clinical/admin fields.
- The model should not be interpreted as a clinical decision tool.

## Portfolio value

This project demonstrates practical data-analysis workflow discipline: cleaning, profiling, feature engineering, baseline modeling, model comparison, and responsible interpretation.
