# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Dimensional Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Complex Data Type and Cumulation Day 1 Lab
| Concept                | Notes            |
|---------------------|------------------|
| **Goal**  | - Create a table with only one row per player <br>&emsp;• Each row should contain a player with an array of each of their seasons <br> &emsp;• If we joined the current `player_seasons` with a downstream table, it causes shuffling<br> &emsp;&emsp;• This is because `player_seasons` has multiple rows for each player<br> &emsp;• We remove the temporal component and push it to its own data type inside   |
| **Method**  | - Look through the table and see what is changing <br> &emsp;• i.e. `player_name`, `draft_year`, etc <br>- Create a struct with `TYPE()`<br> &emsp;• Creates a new table that will include all of the columns at the player level so there is no duplication. <br> &emsp;• Include the array of season stats<br>- Create a `TABLE` <br>- Find the first year in the seasons  |
| **Creating a Struct**  | - See [Creating a Struct](#creating-a-struct-code) below. |
| **Our Table**  | - Create a table with the values that do not change <br> -See [Our Table](#our-table-code) below. |
| **Finding the First Year In Seasons**  | - `SELECT MIN(season) FROM player_seasons;`  |
| **Today/Yesterday Query**  |  - See [Today/Yesterday Query](#todayyesterday-query-code) below. <br>- Gives us the cumulation between yesterday and today <br>- This query as written will return `NULL` for everything under yesterday because we haven't filled any information yet | |
| **Creating the Seed Query**  | - See [Creating the Seed Query](#creating-the-seed-query-code) below. <br>- Currently, this only manages today's values<br>- Seed queries have an initial `NULL` value for yesterday when they are first started|
| **Adding the Seasons Array**  | See [Adding the Seasons Array](#adding-the-seasons-array-code) below. <br>- This creates an array concat which slows the array of all the values<br>- This gives everyone a struct |
| **Account for Current Season**  | See [Account for Current Season](#account-for-current-season-code) below.<br>- NOTE: See [Current Season CASE](#current-season-case-code) below. <br>- Full code: See [Full Account for Current Season](#full-account-for-current-season-code) below. |
| **Create the Pipeline!**  | See [Create the Pipeline](#create-the-pipeline-code) below.<br>- From here, you can load in each year by changing yesterday to 1996 and today as 1997<br>&emsp;• Rinse and repeat until the values are loaded <br>&emsp;• If you query `SELECT * FROM players WHERE current_season = 2001;`, you will be able to see each player's season stats. <br>&emsp;&emsp;• i.e. `{(1995,24,22.0,6.4,2.4), (2001,60,22.9,5.7,5.2)}` <br>- You can cumulate |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |

### Creating a Struct Code
```sql
CREATE TYPE season_stats (
    season INTEGER,

    -- Games played
    gp INTEGER,

    -- Points
    pts REAL,
    reb REAL,

    -- Assist
    ast REAL
)
```

### Our Table Code
```sql
CREATE TABLE players (
    player_name TEXT,
    height TEXT,
    college TEXT,
    country TEXT,
    draft_year TEXT,
    draft_round TEXT,
    draft_number TEXT,
    -- Insert the array
    season_stats season_stats[],
    -- We are developing this table cumulatively! As we do the full
    -- outer joins between the tables, this current season will be
    -- whatever the latest value in the table is
    current_season TEXT,
    PRIMARY KEY(player_name, current_season)
)
```

### Today/Yesterday Query Code

```sql
WITH yesterday AS (
    SELECT * FROM player
    WHERE current_season = 1995
), 
today AS (
    SELECT * FROM player_seasons
    WHERE season = 1996
)
SELECT * FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

### Creating the Seed Query Code
```sql
WITH yesterday AS (
    SELECT * FROM player
    WHERE current_season = 1995
), 
today AS (
    SELECT * FROM player_seasons
    WHERE season = 1996
)
SELECT * FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
SELECT
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number
FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

### Adding the Seasons Array Code

```sql
WITH yesterday AS (
    SELECT * FROM player
    WHERE current_season = 1995
), 
today AS (
    SELECT * FROM player_seasons
    WHERE season = 1996
)
SELECT
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    -- Add the seasons array
    CASE
        WHEN y.season_stats IS NULL THEN ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        ELSE y.season_stats
    END AS season_stats
FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

### Account for Current Season Code
```sql
-- Continued from previous query
CASE
    WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[
        ROW(
            t.season,
            t.gp,
            t.pts,
            t.reb,
            t.ast
        )::season_stats
    ]
    ELSE y.season_stats
END AS season_stats,

-- Gives us our current season value
COALESCE(t.season, y.current_season + 1) AS current_season

FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

### Current Season CASE Code

```sql
CASE
    WHEN t.season IS NOT NULL THEN t.season
    ELSE y.current_season + 1
END
```

### Full Account for Current Season Code

```sql
WITH yesterday AS (
    SELECT * FROM player
    WHERE current_season = 1995
), 
today AS (
    SELECT * FROM player_seasons
    WHERE season = 1996
)
SELECT
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    -- Add the seasons array
    CASE
        WHEN y.season_stats IS NULL THEN ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        ELSE y.season_stats
    END AS season_stats,
    -- Gives us our current season value
    COALESCE(t.season, y.current_season + 1) AS current_season
FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

### Create the Pipeline Code
```sql
INSERT INTO players
WITH yesterday AS (
    SELECT * FROM player
    WHERE current_season = 1995
), 
today AS (
    SELECT * FROM player_seasons
    WHERE season = 1996
)
SELECT
    COALESCE(t.height, y.height) AS height,
    COALESCE(t.college, y.college) AS college,
    COALESCE(t.country, y.country) AS country,
    COALESCE(t.draft_year, y.draft_year) AS draft_year,
    COALESCE(t.draft_round, y.draft_round) AS draft_round,
    COALESCE(t.draft_number, y.draft_number) AS draft_number,
    CASE
        WHEN y.season_stats IS NULL THEN ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        WHEN t.season IS NOT NULL THEN y.season_stats || ARRAY[
            ROW(
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
            )::season_stats
        ]
        ELSE y.season_stats
    END AS season_stats,
    COALESCE(t.season, y.current_season + 1) AS current_season
FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx
