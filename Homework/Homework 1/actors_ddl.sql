-- Create the films struct
CREATE TYPE films AS (
	film TEXT,
	votes INTEGER,
	rating REAL,
	filmid TEXT
)

-- Create an enum for quality_class
CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');


CREATE TABLE actors (
	current_year INTEGER,
	actor TEXT,
	films films[],
	quality_class quality_class,
	is_active BOOLEAN
);
