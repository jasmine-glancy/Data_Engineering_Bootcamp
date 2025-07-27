# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Fact Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Practical Guide to Formatting and Aggregating Data Day 3 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Methodology**  | - [Create array_metrics Table](#create-array_metrics-table) <br> &emsp;• Think of this as 3 partitions <br> &emsp;• We need to have month_start <br>- [Create daily aggregate function](#create-daily-aggregate-function) <br>&emsp;• To replace the `MERGE` functionality<br>- [Create yesterday's aggregation](#create-yesterdays-aggregation) <br>- [Build the array and Fill For the First Day](#build-the-array-and-fill-for-the-first-day) <br>- [Fill the Query For the Second Day](#fill-the-query-for-the-second-day)<br>&emsp;• For every iteration in the data sets, regardless of when a user shows up, everyone should have the same number of elements in an array, but this does not happen in this query<br>&emsp;• [How to fix](#second-day-query-fix-using-array_fill) <br>- Complete dimensional analysis on 3 days <br>&emsp;• [Aggregate and unnest](#aggregate-and-unnest)|

### Create array_metrics Table

```sql
CREATE TABLE array_metrics (
    user_id NUMERIC,
    month_start DATE,
    metric_name TEXT,

    -- You can use INTEGER[] or REAL[] here
    -- You can put an INTEGER[] in a REAL, but you can't 
    ---- put a REAL[] in an INTEGER[]
    metric_array REAL[]
    PRIMARY KEY (user_id, month_start, metric_name)
)
```

### Create Daily Aggregate Function

```sql
WITH daily_aggregate AS (
    SELECT
        user_id,
        COUNT(1) AS num_site_hits
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-01')
    
    -- Filter the NULL results out
    AND user_id IS NOT NULL
    GROUP BY user_id
)

-- View results
SELECT * FROM daily_aggregate 
```

### Create Yesterday's Aggregation

```sql
WITH daily_aggregate AS (
    SELECT
        DATE(event_time) AS date,
        user_id,
        COUNT(1) AS num_site_hits
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-01')
    
    -- Filter the NULL results out
    AND user_id IS NOT NULL
    GROUP BY user_id, DATE(event_time)
),
    yesterday_array AS (
        SELECT * FROM array_metrics
        WHERE month_start = DATE('2023-01-01')
    )

SELECT 
    COALESCE(da.user_id, ya.user_id) AS user_id,

    -- DATE_TRUNC is used because da.date moves forward. As we cumulate up, 
    -- DATE_TRUNC('month', da.date)) will remain month_start
    COALESCE(ya.month_start, DATE_TRUNC('month', da.date)) AS month_start,
    'site_hits' AS metric_name
FROM daily_aggregate da FULL OUTER JOIN yesterday_array ya
    da.user_id = ya.user_id
```

### Build the array and Fill For the First Day

```sql
INSERT INTO array_metrics
WITH daily_aggregate AS (
    SELECT
        DATE(event_time) AS date,
        user_id,
        COUNT(1) AS num_site_hits
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-01')
    
    -- Filter the NULL results out
    AND user_id IS NOT NULL
    GROUP BY user_id, DATE(event_time)
),
    yesterday_array AS (
        SELECT * FROM array_metrics
        WHERE month_start = DATE('2023-01-01')
    )

SELECT 
    COALESCE(da.user_id, ya.user_id) AS user_id,
    COALESCE(ya.month_start, DATE_TRUNC('month', da.date)) AS month_start,
    'site_hits' AS metric_name,
    -- If the ya.metric_array is NOT NULL, then the user already exists
    CASE WHEN ya.metric_array IS NOT NULL THEN
        -- COALESCE to return 0 instead of NULL if num_site_hits is NULL
        ya.metric_array || ARRAY[COALESCE(da.num_site_hits, 0)]
    WHEN ya.metric_array IS NULL THEN
        THEN ARRAY[COALESCE(da.num_site_hits, 0)]
    END AS metric_array
FROM daily_aggregate da FULL OUTER JOIN yesterday_array ya
    da.user_id = ya.user_id

-- Overwrite equivilent 
ON CONFLICT (user_id, month_start, metric_name)
DO
    UPDATE SET metric_array = EXCLUDED.metric_array;
```

### Fill the Query For the Second Day

```sql
INSERT INTO array_metrics
WITH daily_aggregate AS (
    SELECT
        DATE(event_time) AS date,
        user_id,
        COUNT(1) AS num_site_hits
    FROM events
    -- Change the date to the next day
    WHERE DATE(event_time) = DATE('2023-01-02')
    
    -- Filter the NULL results out
    AND user_id IS NOT NULL
    GROUP BY user_id, DATE(event_time)
),
    yesterday_array AS (
        SELECT * FROM array_metrics
        WHERE month_start = DATE('2023-01-01')
    )

SELECT 
    COALESCE(da.user_id, ya.user_id) AS user_id,
    COALESCE(ya.month_start, DATE_TRUNC('month', da.date)) AS month_start,
    'site_hits' AS metric_name,
    -- If the ya.metric_array is NOT NULL, then the user already exists
    CASE WHEN ya.metric_array IS NOT NULL THEN
        -- COALESCE to return 0 instead of NULL if num_site_hits is NULL
        ya.metric_array || ARRAY[COALESCE(da.num_site_hits, 0)]
    WHEN ya.metric_array IS NULL THEN
        THEN ARRAY[COALESCE(da.num_site_hits, 0)]
    END AS metric_array
FROM daily_aggregate da FULL OUTER JOIN yesterday_array ya
    da.user_id = ya.user_id

ON CONFLICT (user_id, month_start, metric_name)
DO
    UPDATE SET metric_array = EXCLUDED.metric_array;
```

### Second Day Query Fix Using ARRAY_FILL

```sql
INSERT INTO array_metrics
WITH daily_aggregate AS (
    SELECT
        DATE(event_time) AS date,
        user_id,
        COUNT(1) AS num_site_hits
    FROM events
    WHERE DATE(event_time) = DATE('2023-01-01')
    
    -- Filter the NULL results out
    AND user_id IS NOT NULL
    GROUP BY user_id, DATE(event_time)
),
    yesterday_array AS (
        SELECT * FROM array_metrics
        WHERE month_start = DATE('2023-01-01')
    )

SELECT 
    COALESCE(da.user_id, ya.user_id) AS user_id,
    COALESCE(ya.month_start, DATE_TRUNC('month', da.date)) AS month_start,
    'site_hits' AS metric_name,
    -- If the ya.metric_array is NOT NULL, then the user already exists
    CASE WHEN ya.metric_array IS NOT NULL THEN
        -- COALESCE to return 0 instead of NULL if num_site_hits is NULL
        ya.metric_array || ARRAY[COALESCE(da.num_site_hits, 0)]
    -- When everything is empty
    WHEN ya.month_start IS NULL THEN ARRAY[COALESCE(da.num_site_hits, 0)]
    WHEN ya.metric_array IS NULL THEN
        -- ARRAY_FILL creates an array of 0s equal to date - month start
        -- This ARRAY can't accept a NULL value, so you have to COALESCE
        -- DATE_TRUNC returns a timestamp, which necessitates the DATE wrapper
        THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) 
            || ARRAY[COALESCE(da.num_site_hits, 0)]
    END AS metric_array
FROM daily_aggregate da FULL OUTER JOIN yesterday_array ya
    da.user_id = ya.user_id

ON CONFLICT (user_id, month_start, metric_name)
DO
    UPDATE SET metric_array = EXCLUDED.metric_array;
```

### Aggregate and Unnest

```sql
WITH agg AS (
SELECT metric_name, month_start, ARRAY[SUM(metric_array[1]),
                          SUM(metric_array[2]),
                          -- Add this line for each value in the array
                          SUM(metric_array[3])
    ] AS summed_array
FROM array_metrics
GROUP BY metric_name, month_start
)

-- Breaks down the elements in each part of the summed_array
SELECT metric_name,
       month_start + CAST(CAST(index - 1 AS TEXT) || 'day' AS INTERVAL),
       elem AS value
    FROM agg 
    CROSS JOIN UNNEST(agg.summed_array) 
        WITH ORDINALITY AS a(elem, index)
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What type was ultimately chosen for the 'metric array' in the data table?
- What query operation is primarily discussed for handling conflicts in PostgreSQL?
- Which function is used in the lab to fill arrays with default values when data is missing?
- What indexing system does PostgreSQL utilize that required adjustment during calculations?
- What key concept is emphasized as being important for every data modeling problem according to the session?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

In the data table, `REAL[]` was chosen because it allows for more flexibility; integers can be included in real numbers. `ON CONFLICT UPDATE` is used in PostgreSQL to handle conflicts, as PostgreSQL doesn't have a native `MERGE` operation. `ARRAY_FILL` is used to create an array with specified default values when certain data points are missing.

PostgreSQL uses one-based indexing, necessitating adjustments such as subtracting 1 when calculating indices. `FULL OUTER JOINS` are emphasized as a crucial concept, as they allow all rows to be combined, which is used frequently in data modeling.
