# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Applying Analytical Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Mastering Growth Accounting and Retention Analysis Day 1 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Create Growth Accounting Code**  | - [Growth Accounting Table](#growth-accounting-table) |
| **Fill the Growth Accounting Table**  | - [Fill the Growth Accounting Table](#fill-the-growth-accounting-table) |
| **Check When Users Show Up**  | `SELECT date, daily_active_state, COUNT(1) FROM users_growth_accounting GROUP BY date, daily_active_state` <br> &emsp;• Shows the date, daily active state, and how many people fell into this state |
| **Analyzing Retention Analysis for Cohorts**  | [Creating a J Curve and Viewing Percent of Active Users](#creating-a-j-curve-and-viewing-percent-of-active-users) <br>|
| **Survival Analysis**  | - [Survivor Analysis](#survivor-analysis) <br> &emsp;• You can also view each day of the week to see which days users are more active<br> &emsp;&emsp;• [Survivor Analysis by Day](#survivor-analysis-by-day) |
### Growth Accounting Table

```sql
CREATE TABLE users_growth_accounting (
    user_id TEXT,
    first_active_date DATE,
    last_active_date DATE,

    -- Growth accounting values
    daily_active_state TEXT,
    weekly_active_state TEXT,

    -- Similar to what was done in week 2
    dates_active DATE[],
    date DATE,
    PRIMARY KEY (user_id, date)
)
```

### Fill the Growth Accounting Table

```sql
INSERT INTO users_growth_accounting
WITH yesterday AS (
    SELECT * FROM users_growth_accounting

    -- These dates can be adjusted to fill the values manually
    WHERE date = DATE(:'2023-02-28')
),
    today AS (
        SELECT
            CAST(user_id AS TEXT) AS user_id,
            DATE_TRUNC('day', event_time::timestamp) AS today_date,
            COUNT(1)
        FROM events
        
        -- These dates can be adjusted to fill the values manually
        WHERE DATE_TRUNC('day', event_time::timestamp) = DATE(:'2023-03-01')
        AND user_id IS NOT NULL
        GROUP BY user_id, DATE_TRUNC('day', event_time::timestamp)
    )

SELECT
        -- The order of these COALESCE statements matters!
        COALESCE(t.user_id, y.user_id) AS user_id,
        COALESCE(y.first_active_date, t.today_date) AS first_active_date,
        COALESCE(t.today_date, y.last_active_date) AS last_active_date,

        CASE 
            WHEN y.user_id IS NULL AND t.user_id IS NOT NULL THEN 'New'
            WHEN y.last_active_date = t.today_date - Interval '1 day' THEN 'Retained' 
            WHEN y.last_active_date < t.today_date - Interval '1 day' THEN 'Resurrected'

            -- y.date is the partition date
            WHEN t.today_date IS NULL AND y.last_active_date = y.date THEN 'Churned'

            ELSE 'Stale'

            END AS daily_active_state,
        CASE
            WHEN y.user_id IS NULL AND t.user_id IS NOT NULL THEN 'New'

            -- Counts users even if they aren't active today
            WHEN y.last_active_date >= y.date - Interval '7 day' THEN 'Retained' 

            -- The user must have been active over  days ago to ensure they have churned
            WHEN y.last_active_date < t.today_date - Interval '1 day' THEN 'Resurrected'

            WHEN t.today_date IS NULL AND y.last_active_date = y.date - '7 day' THEN 'Churned'

            ELSE 'Stale'
        THEN '' END AS weekly_active_state,

        COALESCE(y.dates_active,
            ARRAY[]::DATE[])
             || CASE WHEN
                t.user_id IS NOT NULL
                THEN ARRAY[t.today_date]
                ELSE ARRAY[]::DATE[]
                END AS date_list,
        COALESCE(t.today_date, y.date + Interval '1 day') AS date
    FROM today t
    FULL OUTER JOIN yesterday y
    ON t.user_id = y.user_id
```

### Creating a J Curve and Viewing Percent of Active Users

```sql

-- View over time with a J curve
SELECT date, 
    COUNT(CASE WHEN daily_active_state IN ('Retained', 'Resurrected', 'New') THEN 1 END) AS number_active
FROM users_growth_accounting
WHERE first_active_date = DATE(:'2023-03-01')
GROUP BY date


-- View active users as a percent
-- NOTE: This is good for 1 cohort, but not several
SELECT date, 
    CAST(COUNT(CASE WHEN daily_active_state IN ('Retained', 'Resurrected', 'New') THEN 1 END) AS REAL)/COUNT(1) AS pct_active,
FROM users_growth_accounting
WHERE first_active_date = DATE(:'2023-03-01')
GROUP BY date

```

### Survivor Analysis

```sql
SELECT 
    date - first_active_date AS days_since_first_active, 
    CAST(COUNT(CASE WHEN daily_active_state IN ('Retained', 'Resurrected', 'New') THEN 1 END) AS REAL)/COUNT(1) AS pct_active,
FROM users_growth_accounting
GROUP BY date - first_active_date
```

### Survivor Analysis by Day

```sql
SELECT 
    -- Extract the day of the week from first active day 
    -- as day of the week
    EXTRACT(dow from first_active date) AS dow,
    date - first_active_date AS days_since_first_active, 
    CAST(COUNT(CASE WHEN daily_active_state IN ('Retained', 'Resurrected', 'New') THEN 1 END) AS REAL)/COUNT(1) AS pct_active,
FROM users_growth_accounting
GROUP BY EXTRACT(dow from first_active date), date - first_active_date
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What is the purpose of using the `COALESCE` function in the growth accounting table design?
- In the growth accounting process, when is a user considered "resurrected"?
- What condition defines a user as "retained" on a daily basis?
- How is "stale" status determined for a user in activity tracking?
- For retention analysis, how can one examine cohorts over time?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

The purpose of using the `COALESCE` function in growth accounting table design is to retrieev the first non-null value between the given options. In this lab, cohorts are analyzed by examining the first active date. This enables the study of users' behavior and retention trends over time.

In the growth accounting process, a user is considered "resurrected" if there is a gap in their acvitiy, which indicates if they have returned after a period of inactivity. A user is classified as "retained" if their last active day is today minus one because it indicates consistent daily activity. A user is labed "stale" if they haven't shown activity for more than seven days because it indicates long-term inactivity.
