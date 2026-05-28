# MySQL Workbench Load Guide

## 1. Enable local infile

In MySQL Workbench, open your connection settings and enable local infile loading if available. You may also need to run:

```sql
SET GLOBAL local_infile = 1;
```

If that fails, your MySQL server may not allow changing global variables from your user account.

## 2. Use a simple local path

Put the raw CSV somewhere simple, for example:

```text
C:/Users/scott/Documents/healthcare_dataset.csv
```

Then edit `sql/01_create_and_load.sql`:

```sql
LOAD DATA LOCAL INFILE 'C:/Users/scott/Documents/healthcare_dataset.csv'
```

Use forward slashes in MySQL paths, even on Windows.

## 3. Run scripts in order

1. `01_create_and_load.sql`
2. `02_clean_transform.sql`
3. `03_eda_queries.sql`
4. `04_sql_models.sql`
5. `05_validation_and_export_queries.sql`

## 4. Common MySQL import fixes

### Error 2068: LOAD DATA LOCAL INFILE rejected

Use both:

```sql
SET GLOBAL local_infile = 1;
```

and enable local infile in the Workbench connection advanced settings.

### File path trouble

Avoid OneDrive paths for first import attempts. Copy the file into `C:/Users/scott/Documents/` and use a forward-slash path.

### Header imported as data

Confirm that the script contains:

```sql
IGNORE 1 LINES
```
