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

import org.apache.spark.sql.functions._
import org.apache.spark.storage.StorageLevel

# TODO: Disables automatic broadcast join
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")

# TODO: Build a Spark job that
    # TODO: Explicitly broadcast JOINs medals and maps
