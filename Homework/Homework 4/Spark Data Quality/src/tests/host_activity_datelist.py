from chispa.dataframe_comparer import assert_df_equality 

# Import the function from the actor_history_scd job
from ..jobs.host_activity_datelist_job import do_host_activity_datelist_transformation
from collections import namedtuple

# Create fake data
Event = namedtuple("Event", "user_id device_id referrer host event_time")
CumulatedDatelist = namedtuple("CumulatedDatelist", "host host_activity_datelist date")


def test_cumulated_datelist_generation(spark):
    source_data = [
        Event(21301112, 21231234, "https://www.zachwilson.tech/", "www.zachwilson.tech", "2023-01-18 06:19:08.039000"),
        Event(1234567, 223233, "NULL", "admin.zachwilson.tech", "2023-01-19 16:23:27.685000"),
        Event(1234590, 1982123149, "NULL", "www.eczachly.com", "2023-01-08 22:07:06.171000")
    ]
    source_df = spark.createDataFrame(source_data)
    
    actual_df = do_host_activity_datelist_transformation(spark, source_df)
    expected_data = [
        CumulatedDatelist("www.zachwilson.tech", "2023-01-18", "2023-01-18"),
        CumulatedDatelist("admin.zachwilson.tech", "2023-01-19", "2023-01-19"),
        CumulatedDatelist("www.eczachly.com", "2023-01-08", "2023-01-08")
    ]

    expected_df = spark.createDataFrame(expected_data)
    assert_df_equality(actual_df, expected_df)