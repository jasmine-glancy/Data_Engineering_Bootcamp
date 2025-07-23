# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Fact Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Practical Insights into Data Modeling Day 1 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Methodology**  | - Verify the data in `game_details` with `SELECT * FROM game_details` <br> &emsp;• 1 row is a player and their points<br>- [Check for duplicates](#check-for-duplicates) <br>- Create a filter to get rid of the duplicates <br> &emsp;• [Deduplication](#deduplication) <br>- Comment is high-cardinality fact data <br> &emsp;• [Using POSITION to Examine Raw Data](#using-position-to-examine-raw-data) <br> &emsp;• Keep in mind, did not play/did not dress/not with team all builds on each other (if the team member was not with their team, they didn't dress or play, either) <br>- [Insert Data Into the New Fact Table](#insert-data-into-the-new-fact-table)<br>- [Join teams on fct_game_details](#join-teams-on-fct_game_details) <br>&emsp;• [Example Query](#example-fct_game_details-queries)|

### Check for Duplicates

```sql
SELECT
    game_id, team_id, player_id, COUNT(1)
FROM game_details
GROUP BY 1, 2, 3
HAVING COUNT(1) > 1
```

### Deduplication

```sql
WITH deduped AS (
    SELECT
        -- Used to determine if there are duplicates
        g.game_date_set,
        g.season,
        g.home_team_id,

        -- Keep everything from game details
        gd.*, 
        ROW_NUMBER() OVER (PARTITION BY gd.game_id, team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM game_details gd
    JOIN games g on gd.game_id = g.game_id
)

SELECT 
    game_date_est,
    season,
    team_id,
    team_id = home_team_id AS dim_is_playing_at_home,

    -- Add columns to make the query results more readable
    player_id,
    player_name,
    start_position,

    -- Comment is a high cardinality dimension
    -- NWT (did not travel), DNP (did not play), DND (did not dress)
    comment,
    min,
    fgm, -- field goals made
    fga, -- field goals attempted 
    fg3m, -- 3-pointers made
    fg3a, -- 3-pointers attempted
    ftm, -- free-throws made
    fta, -- free-throws attempted

    -- Rebounds
    oreb,
    dreb,
    reb,
    ast, -- assist
    stl, -- steal
    blk, -- block
    "to" AS turnovers, -- turnover
    pf, -- personal foul
    pts,
    plus_minus

FROM deduped
WHERE row_num = 1
```

### Using POSITION to Examine Raw Data

```sql
WITH deduped AS (
    SELECT
        -- Used to determine if there are duplicates
        g.game_date_set,
        g.season,
        g.home_team_id,

        -- Keep everything from game details
        gd.*, 
        ROW_NUMBER() OVER (PARTITION BY gd.game_id, team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM game_details gd
    JOIN games g on gd.game_id = g.game_id
)

SELECT 
    game_date_est,
    season,
    team_id,
    team_id = home_team_id AS dim_is_playing_at_home,
    player_id,
    player_name,
    start_position,

    -- If position is NULL, flag as false
    COALESCE(POSITION('DNP' in comment), 0) > 0 AS dim_did_not_play,
    COALESCE(POSITION('DND' in comment), 0) > 0 AS dim_did_not_dress,
    COALESCE(POSITION('NWT' in comment), 0) > 0 AS dim_not_with_team,

    -- Change the min column from a string 
    CAST(SPLIT_PART(min, ':', 1) AS REAL)
        + CAST(SPLIT_PART(min, ':', 2) AS REAL)/60 AS minutes
    fgm,
    fga, 
    fg3m,
    fg3a, 
    ftm,
    fta, 

    -- Rebounds
    oreb,
    dreb,
    reb,
    ast, -- assist
    stl, -- steal
    blk, -- block
    "TO" AS turnovers, -- turnover
    pf, -- personal foul
    pts,
    plus_minus
FROM deduped
WHERE row_num = 1
```

### Insert Data Into the New Fact Table

```sql
INSERT INTO fct_game_details
WITH deduped AS (
    SELECT
        -- Used to determine if there are duplicates
        g.game_date_set,
        g.season,
        g.home_team_id,

        -- Keep everything from game details
        gd.*, 
        ROW_NUMBER() OVER (PARTITION BY gd.game_id, team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM game_details gd
    JOIN games g on gd.game_id = g.game_id
)

SELECT 
    game_date_est AS dim_game_date,
    season AS dim_season,
    team_id AS dim_team_id,
    team_id = home_team_id AS dim_is_playing_at_home,
    player_id AS dim_player_id,
    player_name AS dim_player_name,
    start_position AS dim_start_position,

    -- If position is NULL, flag as false
    COALESCE(POSITION('DNP' in comment), 0) > 0 AS dim_did_not_play,
    COALESCE(POSITION('DND' in comment), 0) > 0 AS dim_did_not_dress,
    COALESCE(POSITION('NWT' in comment), 0) > 0 AS dim_not_with_team,

    -- Change the min column from a string 
    CAST(SPLIT_PART(min, ':', 1) AS REAL)
        + CAST(SPLIT_PART(min, ':', 2) AS REAL)/60 AS m_minutes
    fgm AS m_fgm,
    fga AS m_fga, 
    fg3m AS m_fg3m,
    fg3a AS m_fg3a, 
    ftm AS m_ftm,
    fta AS m_fta, 
    oreb AS m_oreb,
    dreb AS m_dreb,
    reb AS m_reb,
    ast AS m_ast,
    stl AS m_stl, 
    blk AS m_blk,
    "TO" AS m_turnovers,
    pf AS m_pf, 
    pts AS m_pts,
    plus_minus AS m_plus_minus
FROM deduped
WHERE row_num = 1

CREATE TABLE fct_game_details (
    -- Columns should be labeled as measures or dimensions
    dim_game_date DATE,
    dim_season INTEGER,
    dim_team_id INTEGER,
    dim_player_id INTEGER,
    dim_player_name TEXT,
    dim_start_position TEXT,
    dim_is_playing_at_home BOOLEAN,
    dim_did_not_play BOOLEAN,
    dim_did_not_dress BOOLEAN,
    dim_not_with_team BOOLEAN,
    m_minutes REAL,
    m_fgm INTEGER,
    m_fga INTEGER,
    m_fg3m INTEGER,
    m_fg3a INTEGER,
    m_ftm INTEGER,
    m_fta INTEGER,
    m_oreb INTEGER,
    m_dreb INTEGER,
    m_reb INTEGER,
    m_ast INTEGER,
    m_stl INTEGER,
    m_blk INTEGER,
    m_turnovers INTEGER,
    m_pf INTEGER,
    m_pts INTEGER,
    m_plus_minus INTEGER, 
    PRIMARY KEY (dim_game_date, dim_team_id, dim_player_id)
)
```

### Join teams on fct_game_details

```sql
SELECT t.*, gd.* FROM fct_game_details gd 
JOIN teams t
ON t.team_id = gd.dim_team_id
```

### Example fct_game_details Queries

```sql
SELECT dim_player_name, COUNT(CASE WHEN dim_not_with_team THEN 1 END) AS bailed_num
FROM fct_game_detail
    GROUP BY 1
ORDER BY 2 DESC

-- Find the percent of games the player bailed on
SELECT dim_player_name,
    COUNT(1) AS num_games,
    COUNT(CASE WHEN dim_not_with_team THEN 1 END) AS bailed_num,
    CAST(COUNT(CASE WHEN dim_not_with_team THEN 1 END) AS REAL)/COUNT(1) AS bail_pct
FROM fct_game_details
    GROUP BY 1
ORDER BY 4 DESC
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx