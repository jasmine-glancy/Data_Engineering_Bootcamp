# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Applying Analytical Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Aggregations and Cardinality Reduction Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Goal**  | - Count the number of signup visits that have happened by browser type, OS type, device type, referer |
| **Create a CTE**  | - [Create the First CTE](#create-the-first-cte) <br> &emsp;• Reduces cardinality |
| **Use a GROUPING SET**  | - [Use GROUPING SET and COALESCE referer_mapped](#use-grouping-set-and-coalesce-referer_mapped) |
| **Handling NULL Results Before the GROUPING SET**  | - Remember, the GROUPING SET turns at NULL and COALESCE will incorrectly turn it to "overall" <br> &emsp;• [Handling NULL Value Example](#handling-null-value-example) |
| **Find Percent Visited Signup**  | - [Find Percent Visited Signup](#find-percent-visited-signup) |
| **Create a Web Events Dashboard**  | - [Create Web Events Dashboard](#create-web-events-dashboard) |
| **Using ROLLUP**  | - The dimensions in this lab don't work very well with `ROLLUP` because they are not hierarchical <br> &emsp;• [ROLLUP Example](#rollup-example) |
| **GROUP BY CUBE Example**  | - [GROUP BY CUBE example](#group-by-cube-example) |
| **Working with Self JOINs**  | - [Working with Self JOINs](#working-with-self-joins) |
| **Grouping User Events by Session**  | - Find how many events a user has in a given session <br> &emsp;• Requires defining what a "session" means <br> &emsp;• We will define a session here as events that the user completed in the same day <br>- [Grouping User Events by Session](#grouping-user-events-by-session) <br>- We want to look at sequential events <br> &emsp;• `ORDER BY` doesn't allow us to filter on a condition (i.e. events that happened in the day) <br>- [Picking the Minimum Time Between Pages](#picking-the-minimum-time-between-pages) |

### Create the First CTE

```sql
WITH combined AS (
    SELECT d.*, we.*,

    -- Reduce the cardinality of referer
    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT referer_mapped, 
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

FROM combined
GROUP BY 1
```

### Use GROUPING SET and COALESCE referer_mapped

```sql
WITH combined AS (
    SELECT d.*, we.*

    -- Reduce the cardinality of referer
    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT COALESCE(referer_mapped, '(overall)') AS referer, 
    COALESCE(browser_type, '(overall)') AS browser_type,
    COALESCE(os_type, '(overall)') AS os_type,
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

FROM combined
GROUP BY GROUPING SETS (
    (referer_mapped, browser_type, os_type),
    (os_type),
    (browser_type),
    (referer_mapped),
    ()
)

ORDER BY COUNT(1) DESC
```

### Handling NULL Value Example

```sql
-- Gives you GROUPING SET Cube/OLAP cube
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT COALESCE(referer_mapped, '(overall)') AS referer, 
    COALESCE(browser_type, '(overall)') AS browser_type,
    COALESCE(os_type, '(overall)') AS os_type,
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

FROM combined
GROUP BY GROUPING SETS (
    (referer_mapped, browser_type, os_type),
    (os_type),
    (browser_type),
    (referer_mapped),
    ()
)

ORDER BY COUNT(1) DESC
```

### Find Percent Visited Signup

```sql
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT COALESCE(referer_mapped, '(overall)') AS referer, 
    COALESCE(browser_type, '(overall)') AS browser_type,
    COALESCE(os_type, '(overall)') AS os_type,
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

    -- Find the percentage of people who signed up
    CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) AS pct_visited_signup

FROM combined
GROUP BY GROUPING SETS (
    (referer_mapped, browser_type, os_type),
    (os_type),
    (browser_type),
    (referer_mapped),
    ()
)

ORDER BY CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) DESC
```

### Create Web Events Dashboard

```sql
CREATE TABLE zachwilson.web_events_dashboard AS
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT COALESCE(referer_mapped, '(overall)') AS referer, 
    COALESCE(browser_type, '(overall)') AS browser_type,
    COALESCE(os_type, '(overall)') AS os_type,
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

    -- Find the percentage of people who signed up
    CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) AS pct_visited_signup

FROM combined
GROUP BY GROUPING SETS (
    (referer_mapped, browser_type, os_type),
    (os_type),
    (browser_type),
    (referer_mapped),
    ()
)

ORDER BY CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) DESC
```

### ROLLUP Example

```sql
CREATE TABLE zachwilson.web_events_dashboard AS
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT COALESCE(referer_mapped, '(overall)') AS referer, 
    COALESCE(browser_type, '(overall)') AS browser_type,
    COALESCE(os_type, '(overall)') AS os_type,
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

    -- Find the percentage of people who signed up
    CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) AS pct_visited_signup

FROM combined

-- ROLLUP gives similar output to GROUPING SETS
GROUP BY ROLLUP (referer_mapped, browser_type, os_type)
HAVING COUNT(1) > 100
ORDER BY CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) DESC
```

### GROUP BY CUBE Example

```sql
CREATE TABLE zachwilson.web_events_dashboard AS
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referer source with a count of each column
SELECT COALESCE(referer_mapped, '(overall)') AS referer, 
    COALESCE(browser_type, '(overall)') AS browser_type,
    COALESCE(os_type, '(overall)') AS os_type,
    COUNT(1) AS number_of_site_hits,
    COUNT(CASE WHEN url = '/signup' THEN 1 END) AS number_of_signup_visits,
    COUNT(CASE WHEN url = '/contact' THEN 1 END) AS number_of_contact_visits,
    COUNT(CASE WHEN url = '/login' THEN 1 END) AS number_of_login_visits,

    -- Find the percentage of people who signed up
    CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) AS pct_visited_signup

FROM combined

-- Using CUBE gets you several more records returned
GROUP BY CUBE (referer_mapped, browser_type, os_type)
ORDER BY CAST(COUNT(CASE WHEN url = '/signup' THEN 1 END) AS REAL)/COUNT(1) DESC
```

### Working with Self JOINs

```sql
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

SELECT * FROM combined
LIMIT 100
```

### Grouping User Events by Session

```sql
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

SELECT c1.url, c2.url, c1.event_time, c2.event_time, 
    c1.event_time - c2.event_time
FROM combined c1 JOIN combined c2
    ON c1.user_id = c2.user_id
    AND DATE(c1.event_time) = DATE(c2.event_time)
    AND c1.event_time > c2.event_time
WHERE c1.user_id = 1067893568
LIMIT 100
```

### Picking the Minimum Time Between Pages

```sql
WITH combined AS (
    SELECT 
        COALESCE(d.browser_type, 'undefined') AS browser_type,
        COALESCE(d.os_type, 'undefined') AS os_type,
        we.*

    CASE 
        WHEN referer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referer LIKE '%eczachly%' THEN 'On Site'
        WHEN referer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referer LIKE '%t.co%' THEN 'Twitter'
        WHEN referer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referer LIKE '%instagram%' THEN 'Instagram'
        WHEN referer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
),
aggregated AS
(
-- Shows all the users and the minimum time it took
-- for a user to go from one page to another
SELECT 
    c1.user_id, c1.url AS to_url, 
    c2.url AS from_url,
    MIN(c1.event_time - c2.event_time) AS duration
FROM combined c1 JOIN combined c2
    ON c1.user_id = c2.user_id
    AND DATE(c1.event_time) = DATE(c2.event_time)
    AND c1.event_time > c2.event_time
GROUP BY c1.user_id, c1.url, c2.url
)

-- Shows the user flows
SELECT to_url, from_url, 
COUNT(1) AS number_of_users
MIN(duration) AS min_duration, 
MAX(duration) AS max_duration,
AVG(duration) AS avg_duration,
FROM aggregated
GROUP BY to_url, from_url

-- Show only flows where at least
-- 1,000 users have done that flow
HAVING COUNT(1) > 1000
LIMIT 100
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- Which SQL clause is useful for obtaining a grand total without listing all detail combinations?
- What is the purpose of reducing the cardinality of a 'referer' column in analytical patterns?
- What is the outcome when using the CUBE operation in grouping sets?
- How does a self-join assist in analyzing user session events?
- What is an effective use of bringing together browser type, OS type, and referer in analytical approaches?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

`ROLLUP` is used to generate subtotals in this lab along with a grand total, without needing to specify every combination of columns like `GROUPING SETS`. Reducing the cardinality of the referer column in this lab helps simplify queries and improve their performance. It does this by reducing the distinct values a column can take, which makes it easier to analyze the columns.

Using the `CUBE` operation in grouping sets generates all possible combinations of combinations of groupings for the columns specified. This creates numerous subtotal and grand total combinations. A self-join enables the analysis of a user's journey by joining a table to itself to find preceding events within a defined session.

Combining the browser_type, os_type, and referrer columns helps us understand user behavior patterns, enabling precise analysis of how users interact with web services across different platforms.
