# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Fact Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Compact Tables for Efficient Data Representation Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Methodology**  | - View table to see the available columns and data <br> &emsp;• `SELECT * FROM events;` <br>- Find the min and max event time <br> &emsp;• `SELECT MAX(event_time), MIN(event_time) FROM events;` <br>- [Create users_cumulated](#create-users_cumulated) <br>- [Examine from January 1st to January 31st](#examine-from-january-1st-to-january-31st) <br>- [Create Each Day Going Forward](#create-each-day-going-forward) <br>- [Match the Existing Table to users_cumulated](#match-the-existing-table-to-users_cumulated-and-insert) <br>- [Build users_cumulated Table For Each Date](#build-users_cumulated-table-for-each-date) <br>- [Generate a Date Series](#generate-a-date-series) <br> &emsp;• Generate a series from 2023-01-02 to 2023-01-31 <br>- [Create a Filtered users Table](#create-a-filtered-users-table) <br>-[Build the Query](#build-the-query)<br>- [Create the Datelist Int for the User](#create-the-datelist-int-for-the-user) <br>- [Cast As BIT(32)](#cast-as-bit32) <br>- [Check Monthly, Weekly, and Daily Active Users](#check-monthly-weekly-and-daily-active-users)|

### Create users_cumulated

```sql
SELECT * FROM events

CREATE TABLE users_cumulated (
    user_id TEXT,

    -- The list of dates in the past where the user was active
    dates_active DATE[],

    -- The current date for the user
    current_date DATE,
    PRIMARY KEY(user_id, date)
);
```

### Examine From January 1st to January 31st

```sql
WITH yesterday AS (
    SELECT 
    *
    FROM users_cumulated
    WHERE date = DATE(:'2022-12-31')
), 
    today AS (

        -- Get all the users active this day
        SELECT 
            user_id,
            DATE(:CAST(event_time AS TIMESTAMP)) AS date_active
        FROM events
        WHERE DATE(:CAST(event_time AS TIMESTAMP)) = DATE(:'2023-01-01')
    )

SELECT * FROM events;
```

### Create Each Day Going Forward

```sql
WITH yesterday AS (
    SELECT 
    *
    FROM users_cumulated
    WHERE date = DATE(:'2022-12-31')
), 
    today AS (

        -- Get all the users active this day
        SELECT 
            user_id,
            DATE(:CAST(event_time AS TIMESTAMP)) AS date_active
        FROM events
        WHERE DATE(:CAST(event_time AS TIMESTAMP)) = DATE(:'2023-01-01')
    )

-- Until you load in for yesterday, the information for yesterday will be NULL
SELECT * FROM today t 
    FULL OUTER JOIN yesterday y
    ON t.user_id = y.user_id
```

### Match the Existing Table to users_cumulated and Insert

```sql
INSERT INTO users_cumulated
WITH yesterday AS (
    SELECT 
    *
    FROM users_cumulated
    WHERE date = DATE(:'2022-12-31')
), 
    today AS (

        -- Get all the users active this day
        SELECT 
            -- We cast this because it is numeric in the logs
            CAST(user_id AS TEXT) AS user_id,
            DATE(:CAST(event_time AS TIMESTAMP)) AS date_active
        FROM events
        WHERE DATE(:CAST(event_time AS TIMESTAMP)) = DATE(:'2023-01-01')
    )


SELECT 
    COALESCE(t.user_id, y.user_id) AS user_id

    -- Fill in dates_active
    CASE WHEN y.dates_active IS NULL
        THEN ARRAY[t.dates_active]

    WHEN t.date_active IS NULL THEN y.dates_active

    -- CONCATS t.dates_active on y.dates_active
    -- Generally, you want the more recent dates to be lower on the index
    ELSE ARRAY [t.dates_active] || y.dates_active
    END AS dates_active,

    COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date

    FROM today t 
    FULL OUTER JOIN yesterday y
    ON t.user_id = y.user_id
```

### Build users_cumulated Table For Each Date

```sql
INSERT INTO users_cumulated
WITH yesterday AS (
    SELECT 
    *
    FROM users_cumulated
    -- Change each date from January 1 to January 31st
    WHERE date = DATE(:'2023-01-01')
), 
    today AS (

        -- Get all the users active this day
        SELECT 
            -- We cast this because it is numeric in the logs
            CAST(user_id AS TEXT) AS user_id,
            DATE(:CAST(event_time AS TIMESTAMP)) AS date_active
        FROM events
        WHERE DATE(:CAST(event_time AS TIMESTAMP)) = DATE(:'2023-01-02')
    )

```

### Generate a Date Series

```sql
SELECT *
FROM generate_series(DATE(:'2023-01-02'), DATE(:'2023-01-31'), INTERVAL '1 day')
```

### Create a Filtered users Table

```sql
WITH users AS (
    SELECT * FROM users_cumulated
    WHERE date = DATE(:'2023-01-31')
)
```

### Build the Query

```sql
WITH users AS (
    SELECT * FROM users_cumulated
    WHERE date = DATE(:'2023-01-31')
)
    series AS (
        SELECT *
        FROM generate_series(DATE(:'2023-01-02'), DATE(:'2023-01-31'), INTERVAL '1 day') AS series_date
    ),

SELECT 
    CASE WHEN
        -- @> means "contains". See if the series is within the active array
        dates_active @> ARRAY [DATE(series_date)]

    -- Create a bitmask or a unique flag for each day the user was active
     THEN POW(2, 32 - (date - DATE(series_date)))
        ELSE 0
            END AS placeholder_int_value,

    *
FROM users CROSS JOIN series

```

### Create the Datelist Int for the User

```sql
WITH users AS (
    SELECT * FROM users_cumulated
    WHERE date = DATE(:'2023-01-31')
)
    series AS (
        SELECT *
        FROM generate_series(DATE(:'2023-01-02'), DATE(:'2023-01-31'), INTERVAL '1 day') AS series_date
    ),
    placeholder_ints AS (
        SELECT CASE 
            WHEN
                dates_active @> ARRAY [DATE(series_date)]
            THEN POW(2, 32 - (date - DATE(series_date)) AS BIGINT)
                ELSE 0
                    END AS placeholder_int_value,

            *
        FROM users CROSS JOIN series
        WHERE user_id = '439578987344044'
    )

SELECT 
    user_id,
    SUM(placeholder_int_value)
FROM placeholder_ints
GROUP BY user_id
```

### Cast As BIT(32)

```sql
WITH users AS (
    -- users_cumulated contains a list of dates a user is active
    SELECT * FROM users_cumulated
    WHERE date = DATE(:'2023-01-31')
)
    series AS (
        SELECT *
        FROM generate_series(DATE(:'2023-01-02'), DATE(:'2023-01-31'), INTERVAL '1 day') AS series_date
    ),
    placeholder_ints AS (
        SELECT CASE 
            WHEN
                dates_active @> ARRAY [DATE(series_date)]

            -- Converts all dates into integer values with the power of 2
            -- If you cast a power of 2 as BITs and you turn it into binary, you can get a history
            THEN POW(2, 32 - (date - DATE(series_date)) AS BIGINT)
                ELSE 0
                    END AS placeholder_int_value,

            *
        FROM users CROSS JOIN series
        WHERE user_id = '439578987344044'
    )

SELECT 
    user_id,
    -- Shows the datelist 
    CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))
FROM placeholder_ints
GROUP BY user_id
```

### Check Monthly, Weekly, and Daily Active Users

```sql
WITH users AS (
    SELECT * FROM users_cumulated
    WHERE date = DATE(:'2023-01-31')
)
    series AS (
        SELECT *
        FROM generate_series(DATE(:'2023-01-02'), DATE(:'2023-01-31'), INTERVAL '1 day') AS series_date
    ),
    placeholder_ints AS (
        SELECT CASE 
            WHEN
                dates_active @> ARRAY [DATE(series_date)]
            THEN POW(2, 32 - (date - DATE(series_date)) AS BIGINT)
                ELSE 0
                    END AS placeholder_int_value,

            *
        FROM users CROSS JOIN series
        WHERE user_id = '439578987344044'
    )

SELECT 
    user_id,
    CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32)),

    -- Bit_count shows how many active days a user has 
    BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0 AS dim_is_monthly_active

    -- If we want to look at a segment like weekly_active
    -- Uses bitwise and. If you have a 1 and a 1, you get a 1 on the output.
    -- If you have a 1 and a 0 or a 0 and a 0, you get a 0

    CAST('1111111000000000000000000000' AS BIT(32)) &
    BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0 AS dim_is_weekly_active

    -- Gets daily active users
    CAST('1000000000000000000000000000' AS BIT(32)) &
    BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0 AS dim_is_daily_active
FROM placeholder_ints
GROUP BY user_id
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What does the robots.txt file on a website primarily do?
- What is the purpose of creating a 'users accumulated' table in the discussed lab?
- Why is a 'bigint' used for user IDs instead of an 'integer'?
- What is the role of the 'Generate series' function in the SQL query?
- How is user activity determined over a 30-day period?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

The robots.txt file on a website is a standard used by websites to communicate with web crawlers and instruct them which parts of the site to avoid or include.

In this lab, we created a `users_accumulated` table is designed to track user activity by recording the days users are active. BIGINT was used for user IDs to allow for storage of much larger values, as integers are limited to 2 billion. `generate_series` is used to create a sequence of dates that can be used for comparisons across a set period. The lab uses bit manipulation to efficiently track which days a user was active, turning each day into a bit flag.
