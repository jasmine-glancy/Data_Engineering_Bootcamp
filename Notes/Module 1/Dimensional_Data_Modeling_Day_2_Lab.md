# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Dimensional Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Building Slowly Changing Dimensions Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Goal**  | - Take the table from lab 1 and turn it into a type 2 SCD<br>  &emsp;• Create an SCD table that tracks changes in 2 columns <br>- Create a table with no filter<br>- Code review: [Starting Point Updated Code](#starting-point-updated-code) |
| **Creating players_scd**  | - [Players SCD](#players-scd-code) <br>  &emsp;• The two columns we are tracking are `scoring_class` and `is_active` <br>  &emsp;• These will change over time |
| **Methodology**  | - Create players_scd <br>- Create a query that fills players_scd <br>- Take an existing SCD and incrementally build on top of it<br> &emsp;• We want to calculate the streak of how long they were in a current dimension<br> &emsp;&emsp;• We do this by looking at what the dimension's results were before using **window functions** |
| **Window Functions**  | - [Window Function Example](#window-function-example) <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |

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
    PRIMARY KEY(player_name, current_season)
);
```

### Window Function Example

```sql
SELECT 
    player_name,
    scoring_class,
    LAG(scoring_class, 1), OVER (PARTITION BY player_name ORDER BY current_season) AS previous_scoring_class,    
    LAG(is_active, 1), OVER (PARTITION BY player_name ORDER BY current_season) AS previous_is_active,
    is_active,
FROM players
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx
