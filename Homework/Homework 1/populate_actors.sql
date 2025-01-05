
-- Find the first year in the table
SELECT MIN(year) FROM actor_films;

INSERT INTO actors
-- Create cumulative table generation query
WITH previous_year AS (
	SELECT * FROM actors
	WHERE current_year = 1969
),
	current_year AS (
		SELECT * FROM actor_films
		WHERE year = 1970
	)

SELECT 
	COALESCE(c.year, p.current_year + 1) AS current_year,
	COALESCE(c.actor, p.actor) AS actor,
	
	-- When the film list is empty, add a new item
	CASE WHEN c.film IS NULL
			THEN ARRAY[ROW(
				c.film,
				c.votes,
				c.rating,
				c.filmid
			)::films]
	WHEN c.film IS NOT NULL THEN p.films || ARRAY[ROW(
				c.film,
				c.votes,
				c.rating,
				c.filmid
			)::films]
	ELSE p.films
	END as films,
	-- make the quality class
	CASE
		WHEN c.year IS NOT NULL THEN
			CASE WHEN c.rating > 8 THEN 'star'
				WHEN c.rating > 7 THEN 'good'
				WHEN c.rating > 6 THEN 'average'
				ELSE 'bad'
				END::quality_class
		ELSE p.quality_class
		END::quality_class,
	CASE WHEN c.year IS NOT NULL THEN true
	ELSE false
	END AS is_active
	

FROM current_year c 
FULL OUTER JOIN previous_year p 
	ON p.current_year = c.year;