-- Deduplicate game_details from Day 1 so there's no duplicates
WITH deduped AS (
	-- Used to determine if there are duplicates
	SELECT
		g.game_date_est,
		g.season,
		g.home_team_id,
		gd.*,
		ROW_NUMBER() OVER (PARTITION BY gd.game_id, team_id, player_id ORDER BY g.game_date_est) AS row_num
	FROM game_details gd
	JOIN games g ON gd.game_id = g.game_id
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
    comment,
    min,
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
	
    ast,
    stl,
    blk,
	-- Change the column name so it isn't a keyword
    "TO" AS turnovers,
    pf,
    pts,
    plus_minus

FROM deduped
WHERE row_num = 1