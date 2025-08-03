-- A query that uses GROUPING SETS to do efficient aggregations of game_details data
WITH combined AS (
    SELECT 
		ps.player_name AS player_name,
		gd.team_id AS team_id,
		gd.team_abbreviation AS team_abbreviation,
		gd.pts AS pts,
		ps.season AS season
    FROM player_seasons ps
    LEFT OUTER JOIN game_details gd
        ON ps.player_name = gd.player_name
)

SELECT
	player_name,
	team_abbreviation,
	season,
	SUM(pts) AS total_points,
	COUNT(*) AS games_played
FROM combined
GROUP BY GROUPING SETS (
    -- Allows you to answer questions like who scored the most points playing for one team?
	(player_name, team_abbreviation),

    -- Allows you to answer questions like who scored the most points in one season?
	(player_name, season),

    -- Allows you to answer questions like which team has won the most games?
	(team_abbreviation),
	()
)
	
ORDER BY total_points DESC NULLS LAST;