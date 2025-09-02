"""
    match_details
            a row for every players performance in a match
    matches
        a row for every match
    medals_matches_players
        a row for every medal type a player gets in a match
    medals
        a row for every medal type
"""

from pyspark.sql.functions import broadcast, split, lit

# Join tables on match_id
val matchesBucketed = spark.read.option("header", "true")
                        .option("inferSchema", "true")
                        .csv("/home/iceberg/data/matches.csv")

val matchesDetailsBucketed = spark.read.option("header", "true")
                        .option("inferSchema", "true")
                        .csv("/home/iceberg/data/match_details.csv")

val medalMatchesPlayersBucketed = spark.read.option("header", "true")
                        .option("inferSchema", "true")
                        .csv("/home/iceberg/data/medal_matches_players.csv")
                        
# Create a new table using iceberg
spark.sql("""DROP TABLE IF EXISTS
          bootcamp.matches_bucketed""")

val bucketedDDL = """
CREATE TABLE IF NOT EXISTS bootcamp.matches_bucketed (
    match_id STRING,
    is_team_gone BOOLEAN,
    playlist_id STRING,
    completion_date TIMESTAMP
)
USING iceberg
PARTITIONED BY (completion_date, bucket(16, match_id))
"""

spark.sql(bucketedDDL)

# TODO: Bucket matches on match_id with 16 buckets
matchesBucketed.select(
    $"match_id", $"is_team_gone", $"playlist_id", $"completion_date")
    .write.mode("append")
    .bucketBy(16, "match_id").saveAsTable("bootcamp.matches_bucketed")
    

val bucketedDetailsDDL = """
CREATE TABLE IF NOT EXISTS bootcamp.matches_details_bucketed (
    match_id STRING,
    player_gamertag BOOLEAN,
    player_total_kills STRING,
    player_total_deaths STRING
)
USING iceberg
PARTITIONED BY (bucket(16, match_id))
"""

spark.sql(bucketedDetailsDDL)

# Bucket match_details on match_id with 16 buckets
matchDetailsBucketed.select(
    $"match_id", $"player_gamertag", $"player_total_kills", $"player_total_deaths")
    .write.mode("append")
    .bucketBy(16, "match_id").saveAsTable("bootcamp.match_details_bucketed")
    

# TODO: Bucket medal_matches_players on match_id with 16 buckets
    
# Disable automatic broadcast join
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")

# Join bucketed match_details, matches, and medal_matches_players 
# tables on the bucketed column
# TODO: Add medal_matches_players to this join
spark.sql("""
            SELECT * FROM bootcamp.match_details_bucketed mdb 
            JOIN bootcamp.matches_bucketed md
                ON mdb.match_id = md.match_id
                AND md.completion_date = DATE('2016-01-01')
          """)

