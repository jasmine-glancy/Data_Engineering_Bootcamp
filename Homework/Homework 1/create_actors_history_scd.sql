
-- TODO: Restructure tables and queries to account for Primary Keys
CREATE TABLE actors_history_scd (
	actor TEXT,
	quality_class quality_class,
	is_active BOOLEAN,
	start_date INTEGER,
	end_date INTEGER
);

WITH last_year_scd AS (
	SELECT * FROM actors_history_scd
	WHERE start_date = 1969
	AND end_date = 1969
),
	historical_scd AS (
		SELECT actor,
		quality_class,
		is_active,
		start_date,
		end_date
		FROM actors_history_scd
		WHERE start_date = 1969
		AND end_date < 1969
	),
	this_year_data AS (
		SELECT * FROM actors
		WHERE current_year = 1970
	),
	unchanged_records AS (
		SELECT ty.actor,
		ty.quality_class,
		ty.is_active,
		ly.start_date,
		ly.end_date AS current_year
		FROM this_year_data ty
		JOIN last_year_scd ly
		ON ty.actor = ly.actor
		WHERE ty.quality_class = ly.quality_class
		AND ty.is_active = ly.is_active
	),
	changed_records AS (
		SELECT ty.actor,
			UNNEST(ARRAY[
			ROW(
				ly.quality_class,
				ly.is_active,
				ly.start_date,
				ly.end_date
			)::actors_history_scd,
			ROW(
				ty.quality_class,
				ty.is_active,
				ty.start_date,
				ty.end_date
			)::actors_history_scd
			]) AS records
		FROM this_year_data ty
		LEFT JOIN last_year_scd ly
		ON ty.actor = ly.actor
		WHERE (ty.quality_class <> ly.quality_class
		OR ty.is_active <> ly.is_active)
	),
	unnested_changed_records AS (
		SELECT actor,
		(records::actors_history_scd).quality_class,
		(records::actors_history_scd).is_active,
		(records::actors_history_scd).start_date,
		(records::actors_history_scd).end_date
		FROM changed_records
	),
	new_records AS (
		SELECT ty.actor,
				ty.quality_class,
				ty.is_active,
				ty.start_date AS start_date,
				ty.current_year AS end_date
		FROM this_year_data ty
		LEFT JOIN last_year_scd ly
		ON ty.actor = ly.actor
		WHERE ly.actor IS NULL
	)

SELECT * FROM historical_scd

UNION ALL

SELECT * FROM unchanged_records

UNION ALL

SELECT * FROM unnested_changed_records

UNION ALL

SELECT * FROM new_records