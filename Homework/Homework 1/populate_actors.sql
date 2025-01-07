
-- Find the first year in the table
SELECT MIN(year) FROM actor_films;


INSERT INTO actors
-- Create cumulative table generation query
WITH previous_year AS (
	    SELECT * FROM actors
	    WHERE current_year = 1969
	),
		this_year AS (
		    SELECT * FROM actor_films
		    WHERE year = 1970
		),
			years AS (
			    SELECT generate_series(1970, 2021) AS year
			),
				people AS (
				    SELECT actor, actorid, MIN(year) AS first_year
				    FROM actor_films
				    GROUP BY actor, actorid
				),
					actors_years AS (
					    SELECT * FROM people
					    JOIN years y
					    ON people.first_year <= y.year
					),
						windowed_data AS (
						    -- Build films arrays
						    SELECT
						        COALESCE(a1.actorid, p.actorid) AS actor_id,
						        ayd.year,
						        ayd.actor,
						        ARRAY_REMOVE(
						            ARRAY_AGG(
						                CASE
						                    WHEN a1.year IS NOT NULL THEN
						                        CAST(
						                            ROW(
						                                a1.film,
						                                a1.year,
						                                a1.votes,
						                                a1.rating,
						                                a1.filmid
						                            ) AS films
						                        )
						                END
						            ) OVER (
						                PARTITION BY ayd.actor
						                ORDER BY COALESCE(a1.year, ayd.year)
						            ),
						            NULL
						        ) AS films
						    FROM actors_years ayd
						    LEFT JOIN actor_films a1
						    ON ayd.actor = a1.actor AND ayd.year = a1.year
						    LEFT JOIN people p
						    ON ayd.actor = p.actor
						    GROUP BY ayd.actor, 
						             a1.film, a1.votes,
						             a1.rating, a1.filmid,
						             a1.actorid, p.actorid, 
						             a1.year, ayd.year
						),
							actor_stats AS (
							    SELECT
							        actor,
							        MAX(votes) AS max_votes
							    FROM actor_films
							    GROUP BY actor
							),
								 -- Makes sure theres only one row per actor
								most_recent_actor_row AS (
								    SELECT DISTINCT ON (wd.actor)
								        wd.actor_id,
								        wd.year,
								        wd.actor,
								        wd.films,
								        s.max_votes
								    FROM windowed_data wd
								    JOIN actor_stats s
								    ON wd.actor = s.actor
								    ORDER BY wd.actor, wd.year DESC
								)
SELECT 
    mra.actor_id AS actor_id,
    mra.year AS current_year,
    mra.actor AS actor,
    -- Populate the films 
    CASE WHEN mra.films IS NULL
        THEN ARRAY[ROW(
            t.film,
            t.year,
            t.votes,
            t.rating,
            t.filmid
        )::films]
        WHEN mra.films IS NOT NULL THEN mra.films || ARRAY[ROW(
            t.film,
            t.year,
            t.votes,
            t.rating,
            t.filmid
        )::films]
        ELSE mra.films
    END as films,
    -- make the quality class
    CASE
        WHEN (mra.films[CARDINALITY(mra.films)]).rating > 8 THEN 'star'
        WHEN (mra.films[CARDINALITY(mra.films)]).rating > 7 THEN 'good'
        WHEN (mra.films[CARDINALITY(mra.films)]).rating > 6 THEN 'average'
        ELSE 'bad'
    END::quality_class,
    (mra.films[CARDINALITY(mra.films)]).year = mra.year AS is_active
FROM this_year t
FULL OUTER JOIN most_recent_actor_row mra 
ON t.year = mra.year
AND t.actor = mra.actor;

-- TODO: Remove NULL values
-- TODO: Successfully populate the actors table