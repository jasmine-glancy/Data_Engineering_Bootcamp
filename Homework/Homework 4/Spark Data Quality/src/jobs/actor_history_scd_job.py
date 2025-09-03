from pyspark.sql import SparkSession

# This job implements SCD Type 2 logic for actor history using SparkSQL.
# It compares actor data from 1969 and 1970, tracking changes in quality_class and is_active.
# The output table records historical, unchanged, changed, and new actor records for 1970.

query = """

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
				ty.actor,
				ly.quality_class,
				ly.is_active,
				ly.start_date,
				ly.end_date
			)::actors_history_scd,
			ROW(
				ty.actor,
				ty.quality_class,
				ty.is_active,
				ty.current_year,
				ty.current_year
			)::actors_history_scd
			]) AS records
		FROM this_year_data ty
		LEFT JOIN last_year_scd ly
		ON ty.actor = ly.actor
		WHERE (ty.quality_class <> ly.quality_class
		OR ty.is_active <> ly.is_active)
	),
	unnested_changed_records AS (
		SELECT
			actor,
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
				ty.current_year AS start_date,
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
"""

def do_actor_history_scd_transformation(spark, dataframe):
    """    Registers the input DataFrame as a temporary view 'actors'
    and runs the SCD transformation SQL. Returns a DataFrame with the 
    updated actor history."""
    
    try:
        dataframe.createOrReplaceTempView("actors")
    except Exception as e:
        print(f"Can't create the temporary view. Exception: {e}")
    return spark.sql(query)

def main():
    """Loads the 'actors' table, applies the SCD transformation, 
    and overwrites the 'actor_history_scd' table"""
    spark = SparkSession.builder \
        .master("local") \
            .appName("actor_history_scd") \
                .getOrCreate()
                
    # Ensure 'actors' table exists before running transformation
    output_df = do_actor_history_scd_transformation(spark, spark.table("actors"))
        
    # Overwrite the output table with new SCD results
    output_df.write.mode("overwrite").insertInto("actor_history_scd")