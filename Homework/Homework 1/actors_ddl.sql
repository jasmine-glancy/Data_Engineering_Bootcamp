-- Create the films struct
CREATE TYPE films AS (
	film TEXT,
	year INTEGER,
	votes INTEGER,
	rating REAL,
	filmid TEXT
)

-- Create an enum for quality_class
CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');

-- Create a DDL for an actors table
CREATE TABLE actors (
	actor_id TEXT,
	current_year INTEGER,
	actor TEXT,
	films films[],
	quality_class quality_class,
	is_active BOOLEAN,
	PRIMARY KEY(actor_id)
);