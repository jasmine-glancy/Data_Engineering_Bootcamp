-- Create an ENUM for state change tracking category control
CREATE TYPE player_status AS ENUM ('New', 'Retired', 'Continued Playing', 'Returned from Retirement', 'Stayed Retired');

-- Create a state change tracking table
CREATE TABLE player_status_tracking (
	player_name TEXT,
	year_first_drafted INTEGER,
	last_active_season INTEGER,
	player_status player_status[],
	seasons_played INTEGER[],
	current_season INTEGER,
	PRIMARY KEY (player_name, current_season)
);
-- Create the insert query 
INSERT INTO player_status_tracking 
WITH player_seasons AS (
    SELECT 
        p.player_name,
        CAST(p.draft_year AS INTEGER) AS year_first_drafted,
        gs.season AS current_season
    FROM players p
    
    -- Creates a dynamic list of dates 
    JOIN LATERAL generate_series(
        CAST(p.draft_year AS INTEGER),
        CAST(p.current_season AS INTEGER)
    ) AS gs(season) ON TRUE
    
	-- Filter out the undrafted players 
    WHERE p.draft_year != 'Undrafted'
),
	status_logic AS (
		-- Fill in the state change cases into one array
	    SELECT
	        ps.player_name,
	        ps.year_first_drafted,
	        ps.current_season,
	        prev.current_season AS last_active_season,
	        CASE
				-- When the player isn't in the table already, they are new
	            WHEN prev.current_season IS NULL THEN 'New'::player_status
				
				-- If the player continued playing from last year, log appropriately
	            WHEN prev.current_season = ps.current_season - 1 THEN 'Continued Playing'::player_status

				-- If the player comes back after being inactive, log appropriately
	            WHEN prev.current_season < ps.current_season - 1 THEN 'Returned from Retirement'::player_status

				-- If there isn't a record for the player this year, they have been retired
				WHEN prev.current_season = prev.current_season - 1 THEN 'Retired'::player_status

				-- Otherwise, the player is considered "stale"
	            ELSE 'Stayed Retired'::player_status
	        END AS player_status
	    FROM player_seasons ps
	    LEFT JOIN player_seasons prev
	        ON ps.player_name = prev.player_name
			-- Join yesterday on today
	        AND prev.current_season = ps.current_season - 1
	)
SELECT
    player_name,
    MIN(year_first_drafted) AS year_first_drafted,
    MAX(current_season) AS last_active_season,
    ARRAY_AGG(player_status ORDER BY current_season) AS player_status,
	-- Fill in each season played
    ARRAY_AGG(DISTINCT current_season ORDER BY current_season) AS seasons_played,
	MAX(current_season) AS current_season
FROM status_logic
GROUP BY player_name;