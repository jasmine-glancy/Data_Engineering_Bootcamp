# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Dimensional Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Building Slowly Changing Dimensions Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Goal**  | - Take the table from lab 1 and turn it into a type 2 SCD<br>  &emsp;• Create an SCD table that tracks changes in 2 columns <br>- Create a table with no filter<br>- Code review: [Starting Point Updated Code](#starting-point-updated-code) |
| **Creating players_scd**  | - [Players SCD](#players-scd-code) <br>  &emsp;• The two columns we are tracking are `scoring_class` and `is_active` <br>  &emsp;• These will change over time |
| **Methodology**  | - Create players_scd <br>- Create a query that fills players_scd <br>- Take an existing SCD and incrementally build on top of it<br> &emsp;• We want to calculate the streak of how long they were in a current dimension<br> &emsp;&emsp;• We do this by looking at what the dimension's results were before using **window functions** |
| **Window Functions**  | - [Window Function Example](#window-function-example) |
| **The Full players_scd Fill Query**  | - [Fill The SCD Table](#fill-the-scd-table) |
| **Cons of the First SCD Table As Written**  | - Expensive parts of the query <br>  &emsp;• The two window functions before you aggregate<br>- Think about how things function! <br>- This query is ***more prone to out of memory exceptions*** and ***SKU***<br>  &emsp;• If you have some dimensions in your data set that are not as slowly-changing as other ones, then you will get a lot of streaks for that specific dimension<br> &emsp;&emsp;• This blows up the cardinality of the SCD table results, which **slows it down** <br> &emsp;&emsp;• This table is better with roughly the same amount of slowly changing dimensions <br>- ***Think about how much data you are working with!*** Not ideal for very large data sets |
| **Another Way To Write SCD Tables**  | - [Second Way To Write An SCD](#second-way-to-write-an-scd) <br>  &emsp;• Incrementally processes data <br> &emsp;• **Assumes scoring_class and is_active are never null!**<br>&emsp;&emsp;• If they are, this query can inappropriately filter out data<br> &emsp;• This query works better in a lot of cases because it is querying a lot less data <br>&emsp;&emsp;• However, there is a sequential problem because each step depends on the previous step, making backfilling difficult|

### Starting Point Updated Code

```sql
CREATE TABLE players (
    player_name TEXT,
    height TEXT,
    college TEXT,
    country TEXT,
    draft_year TEXT,
    draft_round TEXT,
    draft_number TEXT,
    season_stats season_stats[],
    scoring_class scoring_class,
    years_since_last_season
    current_season TEXT,
    is_active BOOLEAN,
    PRIMARY KEY(player_name, current_season)
);

WITH years AS (
    SELECT *
    FROM generate_series(1996, 2022) AS season
),
    p AS (
        SELECT player_name, MIN(season) AS first_season
        FROM player_seasons
        GROUP BY player_name
    ),
    platers_and_seasons AS (
        SELECT *
        FROM p 
            JOIN years y ON p.first_season <= y.season
    )


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

    CASE 
        WHEN t.season IS NOT NULL THEN 
        -- Player was active this season
            CASE WHEN t.pts > 20 THEN 'star'
                WHEN t.pts > 15 THEN 'good'
                WHEN t.pts > 10 THEN 'average'
                ELSE
            END::scoring_class
        
        -- If the players are retired, this still pulls in 
        -- their last recorded scoring class
        ELSE y.scoring_class
    END as scoring_class,

    CASE WHEN t.season IS NOT NULL THEN 0

        -- Increments each year t.season is NULL
        ELSE y.years_since_last_season + 1
            END AS years_since_last_season

    COALESCE(t.season, y.current_season + 1) AS current_season
FROM today t
FULL OUTER JOIN yesterday y
    ON t.player_name = y.player_name
```

### Players SCD Code

```sql
CREATE TABLE players_scd (

    -- Behold, a properly modeled SCD
    player_name TEXT,
    scoring_class scoring_class,
    is_active BOOLEAN,
    start_season INTEGER,
    end_season INTEGER,

    -- Think of this as the "date" partition
    current_season INTEGER,
    PRIMARY KEY(player_name, start_season)
);
```

### Window Function Example

```sql
-- Create a CTE
WITH with_previous AS(
    SELECT 
        player_name,
        current_season,
        scoring_class,
        LAG(scoring_class, 1), OVER (PARTITION BY player_name ORDER BY current_season) AS previous_scoring_class,    
        LAG(is_active, 1), OVER (PARTITION BY player_name ORDER BY current_season) AS previous_is_active,
        is_active,
    FROM players

    -- These results can be filtered further 
    WHERE current_season <= 2021
)
    -- Create a new CTE
    with_indicators AS (
        SELECT *,
        -- Create an indicator of whether or not the columns changed
            CASE 
                -- When scoring_class does not equal previous_scoring_class
                WHEN scoring_class <> previous_scoring_class THEN 1 
                WHEN is_active <> previous_is_active THEN 1 
                ELSE 0 
            END AS change_indicator
        FROM with_previous;
    )
    -- Sum the changes via another window function
    with_streaks AS (
        SELECT *,
            SUM(change_indicator) 
                OVER (PARTITION BY player_name ORDER BY current_season) AS streak_indicator
        FROM with_indicators
    )
    -- We can aggregate on streak_indicator with the following
    -- This is our SCD table!
    SELECT 
            player_name, 
            streak_identifier,
            scoring_class,
            is_active,
            MIN(current_season) AS start_season,
            MAX(current_season) AS end_season

            -- This hard-coded value can be changed
            2021 AS current_season
        FROM with_streaks
    GROUP BY player_name, streak_identifier, is_active, scoring_class
    ORDER BY player_name
```

### Fill The SCD Table

```sql
INSERT INTO players_scd
WITH with_previous AS(
    SELECT 
        player_name,
        current_season,
        scoring_class,
        LAG(scoring_class, 1), OVER (PARTITION BY player_name ORDER BY current_season) AS previous_scoring_class,    
        LAG(is_active, 1), OVER (PARTITION BY player_name ORDER BY current_season) AS previous_is_active,
        is_active,
    FROM players
    WHERE current_season <= 2021
)
    with_indicators AS (
        SELECT *,
            CASE 
                WHEN scoring_class <> previous_scoring_class THEN 1 
                WHEN is_active <> previous_is_active THEN 1 
                ELSE 0 
            END AS change_indicator
        FROM with_previous;
    )
    with_streaks AS (
        SELECT *,
            SUM(change_indicator) 
                OVER (PARTITION BY player_name ORDER BY current_season) AS streak_indicator
        FROM with_indicators
    )
    SELECT 
            player_name, 
            streak_identifier,
            scoring_class,
            is_active,
            MIN(current_season) AS start_season,
            MAX(current_season) AS end_season
            2021 AS current_season
        FROM with_streaks
    GROUP BY player_name, streak_identifier, is_active, scoring_class
    ORDER BY player_name
```

### Second Way To Write An SCD

```sql

-- Create a type for your array later
CREATE TYPE scd_type AS (
    scoring_class scoring_class,
    is_active BOOLEAN,
    start_season INTEGER,
    end_season INTEGER
);

-- Goal: See if things have changed from season to season
WITH last_season_scd AS (
    -- Shows only one record per player
    SELECT * FROM players_scd
    WHERE current_season = 2021
    AND end_season = 2021
),
    historical_scd AS (
        SELECT 
            player_name,
            scoring_class,
            is_active,
            start_season,
            end_season
        FROM players_scd
        WHERE current_season = 2021
        AND end_season < 2021
    ),
        this_season_data AS (
            SELECT * FROM players
            WHERE current_season = 2022
        ),
            unchanged_records AS (
                SELECT
                    ts.player_name,
                    ts.scoring_class,
                    ts.is_active,
                    ls.start_season,
                    ts.current_season AS end_season
                FROM this_season_data ts
                    JOIN last_season_data ls
                    ON ls.player_name = ts.player_name
                WHERE ts.scoring_class = ls.scoring_class
                AND ts.is_active = ls.is_active
            ),
                -- You want to use an array or struct to make one into two 
                -- records when a change happens. You still need both records!

                changed_records AS (
                    SELECT
                        ts.player_name,
                        -- This UNNEST outputs (rank, t/f, year, year)
                        UNNEST(ARRAY[
                            ROW(
                                -- Grab all of the old records
                                ls.scoring_class,
                                ls.is_active,
                                ls.start_season,
                                ls.end_season
                            )::scd_type,
                            ROW(
                                ts.scoring_class,
                                ts.is_active,
                                ts.current_season,
                                ts.current_season
                            )::scd_type,
                        ]) AS records
                    FROM this_season_data ts
                        -- Add a left join vs the regular join
                        -- from unchanged_records
                        LEFT JOIN last_season_data ls
                        ON ls.player_name = ts.player_name

                    WHERE (ts.scoring_class <> ls.scoring_class
                    OR ts.is_active <> ls.is_active)
                ),
                -- Outputs all players with any players with changes
                unnested_changed_records AS (
                    SELECT 
                        player_name,
                        (records::scd_type).scoring_class, 
                        (records::scd_type).is_active, 
                        (records::scd_type).start_season, 
                        (records::scd_type).end_season
                    FROM changed_records
                ),
                new_records AS (
                    SELECT 
                        ts.player_name,
                        ts.scoring_class,
                        ts.is_active,
                        ts.current_season AS start_season,
                        ts.current_season AS end_season,
                    FROM this_season_data ts
                    LEFT JOIN last_season_scd ls
                        ON ts.player_name = ls.player_name
                    WHERE ls.player_name IS NULL
                )

    SELECT * FROM historical_scd
    UNION ALL
    SELECT * FROM unchanged_records
    UNION ALL
    SELECT * FROM unnested_changed_records
    UNION ALL
    SELECT * FROM new_records
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What is the primary goal of the Dimensional Data Modeling Day 2 Lab?
- Why is Slowly Changing Dimension Type 2 considered the gold standard?
- What technologies were mentioned for use in the lab?
- In the process described, what is a significant disadvantage of the original query approach?
- What is suggested as a more efficient way to handle incremental data changes in the lab?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

The lab focused on converting existing datasets into a Slowly Changing Demension (SCD) Type 2 model, which helps in tracking historical data efficiently. SCD Type 2 models are considered the gold standard because they maintain a full history of data changes over time, which is crucial for accurate tracking and reporting. Docker and Postgres are used in the lab to set up the environment and manage the databases required for the hands-on excercises.

The initial query approach can lead to out of memory exceptions and SKU, especially with the data that doesn't change slowly, due to the comprehensive scans involved. A more efficient way to handle incremental data changes involves focusing only on the new and change records. This approach avoids processing unnecessary historical data, improving performance.
