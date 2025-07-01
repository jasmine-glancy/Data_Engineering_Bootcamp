# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Dimensional Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Graph Data Modeling Day 3 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Goal**  | - Build a graph data model <br> &emsp;• Which NBA players play with each other in games <br> &emsp;• Which NBA players are a part of which teams at which time  |
| **Methodology**  | - Create vertices type and table <br>- Create edges type and table <br>- Create games as a vertex type <br>- Create players as a vertex type<br>- Create team as a vertex type<br>- Fill in the edges table<br>- `JOIN` vertices on edges <br>- De-dupe the data set <br>- Create an aggregation of game edges <br>&emsp;• Put the aggregation into a CTE<br>-Fill the edge table with the aggregate of game edges<br>- Verify the output  |
| **Create Vertices**  | - [Create Vertices Table and Type](#create-vertices-table-and-type) <br> &emsp;• Create type, then create table |
| **Create Edges**  | - [Create Edges Table and Type](#create-edges-table-and-type) <br> &emsp;• Remember to *think about the relationships*! |
| **Create Games as a Vertex Type**  | - [Create Games as a Vertex Type](#create-games-as-a-vertex-type) <br> &emsp;• Could be a vertex or an edge |
| **Create Players as a Vertex Type**  | - [Create Players as a Vertex Type](#create-players-as-a-vertex-type)|
| **Create Team as a Vertex Type**  | - [Create Team as a Vertex Type](#create-team-as-a-vertex-type) <br>- [Code to De-Dupe Data](#code-to-de-dupe-data)|
| **Verifying Vertices Count**  | - `SELECT type, COUNT(1) FROM vertices GROUP BY 1` |
| **Filling In The Edge Table**  | - [Filling In The Edge Table](#filling-in-the-edge-table) |
| **Handling Unexpected Duplications**  | - `SELECT` the value that is duplicated <br> &emsp;• [Adjusting The Edge Table to Handle Duplicates](#adjusting-the-edge-table-to-handle-duplicates) |
| **Join Vertices on Edges**  | - [Join Vertices on Edges](#join-vertices-on-edges)|
| **De-Dupe the Data Set**  | - [De-Dupe the Data Set](#de-dupe-the-data-set)|
| **Create an Aggregation of Game Edges**  | - [Create an Aggregation of Game Edges](#create-an-aggregation-of-game-edges)|
| **Put the Aggregation Into a CTE**  | - [Put the Aggregation Into a CTE](#put-the-aggregation-into-a-cte) |
| **Fill the Edge Table with the Game Edges Aggregate**  | - [Fill the Edge Table with the Game Edges Aggregate](#fill-the-edge-table-with-the-game-edges-aggregate) |
| **Verify the Output**  | - [Verify the Output](#verify-the-output) |

### Create Vertices Table and Type

```sql

CREATE TYPE vertex_type 
    AS ENUM('player', 'team', 'game');

CREATE TABLE vertices (
    identifier TEXT,

    -- This will be an enumeration
    type vertex_type,

    -- Postgres doesn't have a map type, but you can use JSON
    properties JSON
    PRIMARY KEY (identifier, type)
);
```

### Create Edges Table and Type

```sql

CREATE TYPE edge_type 
    AS ENUM(
        -- Player connected to a player, but they are on different teams
        'plays_against', 
        -- Player connected to a player and they are on the same team
        'shares_team', 
        -- A player plays *in* a game
        'plays_in',
        -- A player plays *on* a team
        'plays_on'
        )

CREATE TABLE edges (
    subject_identifier TEXT,
    subject_type vertex_type,
    object_identifier TEXT,
    object_type vertex_type,
    edge_type edge_type,
    properties JSON,
    PRIMARY KEY (subject_identifier, 
                 subject_type,
                 object_identifier,
                 object_type,
                 edge_type)
)
```

### Create Games as a Vertex Type

```sql

INSERT INTO vertices
SELECT 
    game_id AS identifier,
    'game'::vertex_type AS type,
    json_build_object(
        'pts_home', pts_home,
        'pts_away', pts_away,
        'winning_team', CASE WHEN home_team_wins = 1 THEN home_team_id ELSE visitior_team_id END
    ) AS properties
FROM games; 
```

### Create Players as a Vertex Type

```sql

INSERT INTO vertices
WITH players_agg AS (
    SELECT 
        player_id AS identifier,

        -- You can put min as well, but you just need ONE value either way
        MAX(player_name) AS player_name,
        COUNT(1) AS number_of_games,
        SUM(pts) AS total_points,
        ARRAY_AGG(DISTINCT team_id) AS teams
    FROM game_details
    GROUP BY player_id
)

-- Check your output this way
SELECT identifier, 'player'::vertex_type,
    json_build_object(
        'player_name', player_name, 
        'number_of_games', number_of_games,
        'total_points', total_points,

        -- This should output as an array
        'teams', teams)

```

### Create Team as a Vertex Type

```sql
INSERT INTO vertices
SELECT 
    team_id AS identifier,
    'team'::vertex_type AS type,
    json_build_object(
        'abbreviation', abbreviation,
        'nickname', nickname,
        'city', city,
        'arena', arena,
        'year_founded', yearfounded
    )
FROM teams;
```

### Code To De-Dupe Data

```sql
INSERT INTO vertices
-- Create a CTE
WITH teams_deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY team_id) AS row_num
    FROM teams
)

SELECT 
    team_id AS identifier,
    'team'::vertex_type AS type,
    json_build_object(
        'abbreviation', abbreviation,
        'nickname', nickname,
        'city', city,
        'arena', arena,
        'year_founded', yearfounded
    )
FROM teams_deduped
WHERE row_num = 1
```

### Filling In The Edge Table

```sql
INSERT INTO edges
SELECT
    player_id AS subject_identifier,
    'player'::vertex_type AS subject_type,
    game_id AS object_identifier,
    'game'::vertex_type AS object_type,
    'plays_in'::edge_type AS edge_type,
    json_build_object(
        'start_position', start_position,
        'pts', pts,
        'team_id', team_id,
        'team_abbreviation', team_abbreviation
    ) AS properties
FROM game_details;
```

### Adjusting The Edge Table to Handle Duplicates

```sql
INSERT INTO edges
-- Create a CTE
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
    FROM game_details
)
SELECT
    player_id AS subject_identifier,
    'player'::vertex_type AS subject_type,
    game_id AS object_identifier,
    'game'::vertex_type AS object_type,
    'plays_in'::edge_type AS edge_type,
    json_build_object(
        'start_position', start_position,
        'pts', pts,
        'team_id', team_id,
        'team_abbreviation', team_abbreviation
    ) AS properties
FROM deduped
WHERE row_num = 1;

-- This query works even if there are no duplicates!
```

### Join Vertices on Edges

```sql
SELECT 
    v.properties->>'player_name', 
        MAX(e.properties->>'pts')
    FROM vertices v JOIN edges e
    ON e.subject_identifier = v.identifier
    AND e.subject_type = v.type
GROUP BY 1
ORDER BY 2 DESC
```

### De-Dupe the Data Set

```sql
-- Create an edge per game
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
    FROM game_details
),
    filtered AS (
        SELECT * FROM deduped
        WHERE row_num = 1
    )

    -- Create an edge for plays_against between two players
    -- This creates two edges via a self JOIN
    SELECT
            f1.player_id,
            f1.player_name,
            f2.player_id
            f2.player_name,
            CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                THEN 'shares_team'::edge_type
            ELSE 'plays_against'::edge_type
            END
        FROM filtered f1 JOIN filtered f2
        ON f1.game_id = f2.game_id
        AND f1.player_name <> f2.player_name
```

### Create an Aggregation of Game Edges

```sql
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
    FROM game_details
),
    filtered AS (
        SELECT * FROM deduped
        WHERE row_num = 1
    )

    SELECT
            f1.player_id,
            f1.player_name,
            f2.player_id
            f2.player_name,
            CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                THEN 'shares_team'::edge_type
            ELSE 'plays_against'::edge_type
            END,
            COUNT(1) AS num_games,
            SUM(f1.pts) AS left_points,
            SUM(f2.pts) AS right_points
        FROM filtered f1 JOIN filtered f2
        ON f1.game_id = f2.game_id
        AND f1.player_name <> f2.player_name
    WHERE f1.player_id > f2.player_id
    GROUP BY f1.player_id,
            f1.player_name,
            f2.player_id
            f2.player_name,
            CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                THEN 'shares_team'::edge_type
            ELSE 'plays_against'::edge_type
            END;
```

### Put the Aggregation Into a CTE

```sql
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
    FROM game_details
),
    filtered AS (
        SELECT * FROM deduped
        WHERE row_num = 1
    ),
        aggregated AS (
            SELECT
                    -- Build out your identifiers
                    f1.player_id AS subject_player_id,
                    f2.player_id AS object_player_id,
                    CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                        THEN 'shares_team'::edge_type
                    ELSE 'plays_against'::edge_type
                    END AS edge_type,
                        MAX(f1.player_name) AS subject_player_name,
                        MAX(f2.player_name) AS object_player_name,
                    COUNT(1) AS num_games,
                    SUM(f1.pts) AS left_points,
                    SUM(f2.pts) AS right_points
                FROM filtered f1 JOIN filtered f2
                ON f1.game_id = f2.game_id
                AND f1.player_name <> f2.player_name
            WHERE f1.player_id > f2.player_id
            GROUP BY f1.player_id,
                    f1.player_name,
                    f2.player_id
                    f2.player_name,
                    CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                        THEN 'shares_team'::edge_type
                    ELSE 'plays_against'::edge_type
                    END
        )

        SELECT 
            subject_player_id AS subject_identifier,
            'player'::vertex_type AS subject_type,
            object_player_id = object_identifier,
            'player'::vertex_type AS object_type,
            edge_type AS edge_type,
            json_build_object(
                'num_games', num_games,
                'subject_points', subject_points,
                'object_points', object_points
            )
        FROM aggregated
```

### Fill the Edge Table with the Game Edges Aggregate

```sql
INSERT INTO
WITH deduped AS (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY player_id, game_id) AS row_num
    FROM game_details
),
    filtered AS (
        SELECT * FROM deduped
        WHERE row_num = 1
    ),
        aggregated AS (
            SELECT
                    -- Build out your identifiers
                    f1.player_id AS subject_player_id,
                    f2.player_id AS object_player_id,
                    CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                        THEN 'shares_team'::edge_type
                    ELSE 'plays_against'::edge_type
                    END AS edge_type,
                        MAX(f1.player_name) AS subject_player_name,
                        MAX(f2.player_name) AS object_player_name,
                    COUNT(1) AS num_games,
                    SUM(f1.pts) AS left_points,
                    SUM(f2.pts) AS right_points
                FROM filtered f1 JOIN filtered f2
                ON f1.game_id = f2.game_id
                AND f1.player_name <> f2.player_name
            WHERE f1.player_id > f2.player_id
            GROUP BY f1.player_id,
                    f1.player_name,
                    f2.player_id
                    f2.player_name,
                    CASE WHEN f1.team_abbreviation = f2.team_abbreviation 
                        THEN 'shares_team'::edge_type
                    ELSE 'plays_against'::edge_type
                    END
        )

        SELECT 
            subject_player_id AS subject_identifier,
            'player'::vertex_type AS subject_type,
            object_player_id = object_identifier,
            'player'::vertex_type AS object_type,
            edge_type AS edge_type,
            json_build_object(
                'num_games', num_games,
                'subject_points', subject_points,
                'object_points', object_points
            )
        FROM aggregated
```

### Verify the Output

```sql
SELECT 
        v.properties->>'player_name',
        e.object_identifier,
        CAST(v.properties->>'number_of_games' AS REAL)/
        CASE WHEN CAST(v.properties->>'total_points' AS REAL) = 0 THEN 1 ELSE
    CAST(v.properties->>'total_points' AS REAL) END,
    e.properties->>'subject_points',
    e.properties->>'num_games'
    FROM vertices v JOIN edges e
    ON v.identifier = e.subject_identifer
    AND v.type = e.subject_type 
WHERE e.object_type = 'player'::vertex_type
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What is the purpose of creating a 'vertices' table in the lab?
- Which data type is suggested for storing properties in the 'vertices' table?
- What is the primary key combination for the 'edges' table according to the lab setup?
- How can a self-join help in identifying the 'plays against' relationship between NBA players?
- Why use ENUM types for vertex and edge types in the lab's data modeling?
- What is one of the prerequisites mentioned for the lab session related to Dimensional Data Modeling?
- What type of data structure is used to manage complex relationships in the lab?
- In the lab, what is defined as an enumeration type?
- Which SQL type is used to store properties due to the lack of a map type in PostgreSQL?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

The installation of Docker was needed to set up the environment for the hands-on excersize of the lab session. The lab focuses on building a graph data model to analyze relationships between NBA plays and teams.

Vertices store identifiers, types, and properties in the context of graph data modeling. Since PostgreSQL does not have a MAP type, we used the JSON data type to allow for flexible data storage. The primary key for the `edges` table consists of almost all columns (subject identifier, subject type, object identifier, object type, edge type) except for properties. This uniquely identifies each edge.

A self-join on the player data table using game IDs helps identify pairs of players who played in the same game, thus  establishing a 'plays against' relationship. ENUMs provide a fixed set of potential values, which ensures consistency and helps catch data quality issues like misspellings or incorrect data assignments. The vertex type is defined as an enumeration to differentiate between different entities like player, team, and game.
