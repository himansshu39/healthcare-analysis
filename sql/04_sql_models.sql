-- 04_sql_models.sql
-- SQL-only baseline models.
-- These are intentionally transparent models suitable for a SQL portfolio project.

USE healthcare_mysql_project;

DROP VIEW IF EXISTS healthcare_model_base;
CREATE VIEW healthcare_model_base AS
SELECT
    *,
    CASE WHEN MOD(CRC32(encounter_id), 10) < 8 THEN 'train' ELSE 'test' END AS model_split
FROM healthcare_clean
WHERE billing_amount IS NOT NULL
  AND length_of_stay_days IS NOT NULL
  AND age IS NOT NULL;

-- ----------------------------
-- Model A: billing regression by grouped training averages.
-- ----------------------------
DROP TABLE IF EXISTS model_billing_condition_avg;
CREATE TABLE model_billing_condition_avg AS
SELECT
    medical_condition,
    AVG(billing_amount) AS pred_billing_condition_avg,
    COUNT(*) AS train_rows
FROM healthcare_model_base
WHERE model_split = 'train'
GROUP BY medical_condition;

DROP TABLE IF EXISTS model_billing_group_avg;
CREATE TABLE model_billing_group_avg AS
SELECT
    medical_condition,
    admission_type,
    insurance_provider,
    age_group,
    length_of_stay_bucket,
    AVG(billing_amount) AS pred_billing_group_avg,
    COUNT(*) AS train_rows
FROM healthcare_model_base
WHERE model_split = 'train'
GROUP BY medical_condition, admission_type, insurance_provider, age_group, length_of_stay_bucket;

DROP VIEW IF EXISTS pred_billing_sql_model;
CREATE VIEW pred_billing_sql_model AS
WITH global_avg AS (
    SELECT AVG(billing_amount) AS pred_billing_global_avg
    FROM healthcare_model_base
    WHERE model_split = 'train'
)
SELECT
    t.encounter_id,
    t.billing_amount AS actual_billing_amount,
    g.pred_billing_global_avg,
    COALESCE(c.pred_billing_condition_avg, g.pred_billing_global_avg) AS pred_billing_condition_avg,
    COALESCE(bg.pred_billing_group_avg, c.pred_billing_condition_avg, g.pred_billing_global_avg) AS pred_billing_group_avg
FROM healthcare_model_base t
CROSS JOIN global_avg g
LEFT JOIN model_billing_condition_avg c
    ON t.medical_condition = c.medical_condition
LEFT JOIN model_billing_group_avg bg
    ON t.medical_condition = bg.medical_condition
   AND t.admission_type = bg.admission_type
   AND t.insurance_provider = bg.insurance_provider
   AND t.age_group = bg.age_group
   AND t.length_of_stay_bucket = bg.length_of_stay_bucket
WHERE t.model_split = 'test';

-- Regression metrics: MAE, RMSE, R-squared.
WITH test_mean AS (
    SELECT AVG(actual_billing_amount) AS ybar FROM pred_billing_sql_model
), long_preds AS (
    SELECT 'billing_global_mean' AS model, actual_billing_amount, pred_billing_global_avg AS prediction FROM pred_billing_sql_model
    UNION ALL
    SELECT 'billing_condition_average', actual_billing_amount, pred_billing_condition_avg FROM pred_billing_sql_model
    UNION ALL
    SELECT 'billing_group_average_sql_model', actual_billing_amount, pred_billing_group_avg FROM pred_billing_sql_model
)
SELECT
    model,
    COUNT(*) AS test_rows,
    ROUND(AVG(ABS(actual_billing_amount - prediction)), 2) AS mae,
    ROUND(SQRT(AVG(POW(actual_billing_amount - prediction, 2))), 2) AS rmse,
    ROUND(1 - SUM(POW(actual_billing_amount - prediction, 2)) /
              SUM(POW(actual_billing_amount - (SELECT ybar FROM test_mean), 2)), 4) AS r2
FROM long_preds
GROUP BY model
ORDER BY r2 DESC;

-- ----------------------------
-- Model B: test-results classification by grouped training majority class.
-- ----------------------------
DROP TABLE IF EXISTS model_test_result_global_majority;
CREATE TABLE model_test_result_global_majority AS
SELECT test_results AS global_prediction
FROM healthcare_model_base
WHERE model_split = 'train'
GROUP BY test_results
ORDER BY COUNT(*) DESC, test_results
LIMIT 1;

DROP TABLE IF EXISTS model_test_result_group_majority;
CREATE TABLE model_test_result_group_majority AS
WITH grouped AS (
    SELECT
        medical_condition,
        admission_type,
        medication,
        age_group,
        test_results,
        COUNT(*) AS train_rows,
        ROW_NUMBER() OVER (
            PARTITION BY medical_condition, admission_type, medication, age_group
            ORDER BY COUNT(*) DESC, test_results
        ) AS rn
    FROM healthcare_model_base
    WHERE model_split = 'train'
    GROUP BY medical_condition, admission_type, medication, age_group, test_results
)
SELECT
    medical_condition,
    admission_type,
    medication,
    age_group,
    test_results AS predicted_test_results,
    train_rows
FROM grouped
WHERE rn = 1;

DROP VIEW IF EXISTS pred_test_result_sql_model;
CREATE VIEW pred_test_result_sql_model AS
SELECT
    t.encounter_id,
    t.test_results AS actual_test_results,
    g.global_prediction AS pred_global_majority,
    COALESCE(m.predicted_test_results, g.global_prediction) AS pred_group_majority
FROM healthcare_model_base t
CROSS JOIN model_test_result_global_majority g
LEFT JOIN model_test_result_group_majority m
    ON t.medical_condition = m.medical_condition
   AND t.admission_type = m.admission_type
   AND t.medication = m.medication
   AND t.age_group = m.age_group
WHERE t.model_split = 'test';

-- Accuracy for classification models.
SELECT
    'test_result_global_majority' AS model,
    COUNT(*) AS test_rows,
    ROUND(AVG(actual_test_results = pred_global_majority), 4) AS accuracy
FROM pred_test_result_sql_model
UNION ALL
SELECT
    'test_result_group_majority_sql_model' AS model,
    COUNT(*) AS test_rows,
    ROUND(AVG(actual_test_results = pred_group_majority), 4) AS accuracy
FROM pred_test_result_sql_model;

-- Per-label precision/recall/F1 for the group-majority classifier.
WITH labels AS (
    SELECT DISTINCT test_results AS label FROM healthcare_model_base
), confusion AS (
    SELECT
        l.label,
        SUM(p.actual_test_results = l.label AND p.pred_group_majority = l.label) AS tp,
        SUM(p.actual_test_results <> l.label AND p.pred_group_majority = l.label) AS fp,
        SUM(p.actual_test_results = l.label AND p.pred_group_majority <> l.label) AS fn
    FROM labels l
    CROSS JOIN pred_test_result_sql_model p
    GROUP BY l.label
), scored AS (
    SELECT
        label,
        tp,
        fp,
        fn,
        tp / NULLIF(tp + fp, 0) AS precision_score,
        tp / NULLIF(tp + fn, 0) AS recall_score
    FROM confusion
)
SELECT
    label,
    tp,
    fp,
    fn,
    ROUND(precision_score, 4) AS precision_score,
    ROUND(recall_score, 4) AS recall_score,
    ROUND(2 * precision_score * recall_score / NULLIF(precision_score + recall_score, 0), 4) AS f1_score
FROM scored
ORDER BY label;
