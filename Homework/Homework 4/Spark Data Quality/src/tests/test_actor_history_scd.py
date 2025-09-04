from chispa.dataframe_comparer import assert_df_equality 

# Import the function from the actor_history_scd job
from ..jobs.actor_history_scd_job import do_actor_history_scd_transformation
from collections import namedtuple

# Create fake data
ActorYear = namedtuple("ActorYear", "actor current_year quality_class")
ActorScd = namedtuple("ActorScd", "actor quality_class start_date end_date")


def test_actor_scd_generation(spark):
    source_data = [
        ActorYear("50 Cent", 2005, "bad"),
        ActorYear("Abby Quinn", 2014, "average"),
        ActorYear("Adam Sandler", 1989, "bad")
    ]
    source_df = spark.createDataFrame(source_data)
    
    actual_df = do_actor_history_scd_transformation(spark, source_df)
    expected_data = [
        ActorScd("50 Cent", "bad", 2005, 2019),
        ActorScd("Abby Quinn", "average", 2014, 2020),
        ActorScd("Adam Sandler", "bad", 1989, 2020)
    ]

    expected_df = spark.createDataFrame(expected_data)
    assert_df_equality(actual_df, expected_df)
