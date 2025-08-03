/*************
Queries that use window functions on game_details to find out the following:
    - What is the most games a team has won in a 90 game stretch?
    - How many games in a row did LeBron James score over 10 points a game?
*************/

-- 1. What is the most games a team has won in a 90 game stretch?
WITH count_wins AS (
    -- If the home team wins, mark it
    SELECT 
        game_id
        game_date_est, 
        home_team_id AS team_id, 
        CASE WHEN home_team_wins = 1 THEN 1 ELSE 0 END AS is_win 
    FROM games
    UNION ALL

    -- If the home team loses, mark it
    SELECT 
        game_id
        game_date_est,
        visitor_team_id AS team_id, 
        CASE WHEN home_team_wins = 0 THEN 1 ELSE 0 END AS is_win 
    FROM games
),
    team_games AS (
        SELECT
            team_id,
            game_date_est,
            is_win,
            ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY game_date_est) AS game_seq
        FROM count_wins
    ),
        win_streak AS (
            /*************
                Counts the wins in a 90 game stretch
            *************/
            SELECT 
                team_id,
                game_seq,
                SUM(is_win)
                    OVER (
                        PARTITION BY team_id
                        ORDER BY game_seq 
                        ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
                    ) AS team_wins_in_90_games
            FROM team_games
        )

    SELECT 
        team_id,
        MAX(team_wins_in_90_games) AS max_wins_in_90_games
    FROM win_streak
    GROUP BY team_id
    ORDER BY max_wins_in_90_games DESC;


-- 2. How many games in a row did LeBron James score over 10 points a game?      
WITH team_and_player_info AS (
    /*************
        Joins games on game_details to bring in player name and approximate date
    *************/
	SELECT 
		g.game_date_est AS game_date_est,
		gd.game_id AS game_id,
		gd.team_id AS team_id,
		gd.team_abbreviation AS team_abbreviation,
		gd.team_city AS team_city,
		gd.player_name AS player_name,
		gd.pts AS pts
	FROM game_details gd
	LEFT OUTER JOIN games g
		ON gd.game_id = g.game_id
),
	streak_counter AS (
        /*************
            Use window function to count games with over 10 points
        *************/
		SELECT
			game_date_est,
			game_id,
			player_name,
			CASE WHEN pts > 10 THEN 1 ELSE 0 END AS over_10_pts,
			SUM(CASE WHEN pts <= 10 THEN 1 ELSE 0 END)
				OVER (PARTITION BY player_name ORDER BY game_date_est) AS streak_break_id
		FROM team_and_player_info

	),
		streak_length_counter AS (
            /*************
                Count the streak total
            *************/
			SELECT 
				player_name,
				streak_break_id,
				COUNT(*) AS streak_length
			FROM streak_counter
			WHERE over_10_pts = 1
			GROUP BY player_name, streak_break_id
		)

	SELECT 
		player_name,
		MAX(streak_length) AS longest_streak
	FROM streak_length_counter
	WHERE player_name = 'LeBron James'
	GROUP BY player_name;