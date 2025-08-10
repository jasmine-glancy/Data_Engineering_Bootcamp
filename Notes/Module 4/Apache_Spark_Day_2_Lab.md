# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Apache Spark

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> User-Defined Functions and Broadcast Join Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Installing/Setup**  | - [Go to the Data Engineer Handbook on GitHub](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/bootcamp/materials/3-spark-fundamentals) <br> &emsp;• You can run `make up` or `docker compose up` <br> &emsp;• This sets up a container for iceberg, minio, mc, et. cetra|
| **Lab Code**  | - [Starting Lab Code](#starting-lab-code) <br> &emsp;• If you are trying to serialize something into the dataset API or you're trying to convert data into the dataset API, if it's nullable, you have to wrap it in `Option[]` <br> &emsp;• If the value is not nullable, you can keep the data type as-is <br>- [Create a Function toUpperCase](#create-a-function-touppercase) <br>- [Creating Dummy Data](#creating-dummy-data)|
| **Caching Lab Code**  | - [Caching Lab Code](#caching-lab-code) <br> &emsp;• This code matches a user to all of their devices and a device to all of their users <br> &emsp;• We want to aggregate on the user_id and device_id first <br> &emsp;• An example of a pipeline where we use the same dataframe multiple times<br>- ***Remember, you only get the benefit from `.cached()` if you run the query again!***<br> &emsp;• You will see more benefit the second time because it will read the result set and then it will read the cached information every time after the initial query is ran <br> &emsp;• ***For caching, you really want to be using the dataset more than one time, or there's no reason to cache it!***|
| **Explain Tips**  | - When looking at a query plan, it can help to go to a text difference processor to compare multiples at once <br> &emsp;• If you see "InMemoryTableScan", it means this information is read from memory instead as opposed to the CSV file initially |
| **Persist**  | - `.persist(StorageLevel.DISK_ONLY)` <br> &emsp;• If you are thinking of using this query, [this is a better way](#persist) |
| **Bucket Joins in Iceberg** | - [Bucket Joins](#bucket-joins)<br> &emsp;• Using `.explain()`, if you see `BatchScan`, this means it is a bucketed scan<br> &emsp;• At a larger scale, bucket joining is much more efficient! |

### Starting Lab Code

```sql
import org.apache.spark.sql.SparkSession
import java.util.Date
val sparkSession = SparkSession.builder.appName("Juptyer").getOrCreate()

/* Ways to describe schema in Spark */

-- Illustrate how this fails if you change from Option[String] to Strong for referrer
case class Event (
    -- Option is a way to handle NULL more gracefully
    user_id: Option[Integer],
    device_id: Option[Integer],
    referrer: String,
    host: String,
    url: String,
    event_time: String
)

-- Illustrate how this fails if you change from Option[Long] to Long
case class Device (
    device_id: Integer,
    browser_type: String,
    os_type: String,
    device_type: String
)

case class EventWithDeviceInfo (
    user_id: Integer,
    device_id: Integer,
    browser_type: String,
    os_type: String,
    device_type: String,
    referrer: String,
    host: String,
    url: String,
    event_time: String
)

-- When should you use each type?
import sparkSession.implicits._

-- Applying this case class beforehand is very powerful! Enforces nullability/non-nullability at runtime!
val events: Dataset[Event] = sparkSession.read.option("header", "true")
                        .option("inferSchema", "true")

                        -- Read the CSV
                        .csv("/home/iceberg/data/events.csv")

                        -- As creates a dataset of the events
                        .as(Event)

val devices: Dataset[Device] = sparkSession.read.option("header", "true")
                        .option("inferSchema", "true")
                        .csv("/home/iceberg/data/devices.csv")
                        .as(Device)

-- -- Debugging                      
-- devices.where($"device_id".isNull).show()
-- events.where($"device_id".isNull).show()

devices.createOrReplaceTempView("devices")
events.createOrReplaceTempView("events")

/*************
    For simple transformations, you can see these approaches are very similar. Dataset is winning slightly because of the quality enforcement.

    The three syntaxes below do exactly the same thing and return the exact same dataset! 
**************/

-- Checks to see if the user_id and device_id are there and filtering out those columns when they're not there
val filteredViaDataset = events.filter(event => event.user_id.isDefined && event.device_id.isDefined)
val filteredViaDataFrame = events.toDF().where($"user_id".isNotNull && $"device_id".isNotNull)
val filteredViaSparkSql = sparkSession.sql("SELECT * FROM events WHERE user_id IS NOT NULL AND device_id IS NOT NULL")


/*************
    Combining datasets
**************/

-- This will fail if user_id is None! Remember to manage null.
val combinedDatasets = events
    .joinWith(devices, events("device_id") === devices("device_id"), "inner")
    -- Gives you access to both datasets, schemas, and types and maps it to a new schema
    .map{ case (event: Event, device: Device) => EventWithDeviceInfo(

        -- You can also use user_id=event.user_id.getOrElse(insertDefaultIDHere)
        -- We can use .get here because we are filtering out null values in the previous lines
        user_id=event.user_id.get,
        device_id=device.device_id,
        browser_type=device.browser_type,
        os_type=device.os_type,
        device_type=device.device_type,
        referrer=event.referrer,
        host=event.host,
        url=event.url,
        event_time=event.event_time
    ) }

/*************
    DataFrames
**************/

-- DataFrames give up some of the intellisense because you no longer have static typing
val combinedViaDataFrames = filterdViaDataFrame.as("e")
    -- Make sure to use triple equals when using data frames!
    .join(devices.as("d"), $"e.device_id" === $"d.device_id", "inner")
    .select(
        -- col("e.user_id") gives you the same setup
        $"e.user_id",
        $"d.device_id",
        $"d.browser_type",
        $"d.os_type",
        $"e.referrer",
        $"e.host",
        $"e.url",
        $"e.event_time",
    )

/*************
    SparkSQL and Temp Views
**************/

-- Creating temp views is a good strategy if you're leveraging SparkSQL
filteredViaSparlSql.createOrReplaceTempView("filtered_events")
val combinedViaSparlSQL = spark.sql(f"""
    SELECT
        fe.user_id,
        d.device_id,
        d.browser_type,
        d.os_type,
        d.device_type,
        fe.referrer,
        fe.host,
        fe.url,
        fe.event_time
    FROM filtered_events fe
    JOIN devices d ON fe.device_id = d.device_id
""")

combinedViaDatasets.take(5)
```

### Create a Function toUpperCase

```sql
def toUpperCase(s: String): String{
    return s.toUpperCase()
}

-- Example use case:
val combinedDatasets = events
    .joinWith(devices, events("device_id") === devices("device_id"), "inner")
    .map{ case (event: Event, device: Device) => EventWithDeviceInfo(
        user_id=event.user_id.get,
        device_id=device.device_id,
        browser_type=device.browser_type,
        os_type=device.os_type,
        device_type=device.device_type,
        referrer=event.referrer,
        host=event.host,
        url=event.url,
        event_time=event.event_time
    ) }

    -- If you wanted to turn the browser_type and
    -- device_type to uppercase, you can call map in the dataset API
    .map( case (row: EventWithDeviceInfo) => {
        val upperBrowserType = toUpperCase(row.browser_type)

        row.browser_type = toUpperCase(row.browser_type)
        return row
    })

-- An example use case with the DataFrame API
-- the _ means you are passing a function as a value
val toUpperCaseUdf = udf(toUpperCase _)

val combinedViaDataFrames = filterdViaDataFrame.as("e")
    .join(devices.as("d"), $"e.device_id" === $"d.device_id", "inner")
    .select(
        $"e.user_id",
        $"d.device_id",
        toUpperCaseUdf($"d.browser_type").as("browser_type"),
        $"d.os_type",
        $"e.referrer",
        $"e.host",
        $"e.url",
        $"e.event_time",
    )
```

### Creating Dummy Data

```sql
dummyData = List(
    Event(user_id=1, device_id=2, referrer="linkedin", host="eczachly.com", url="/signup", event_time="2023-01-01"),
    Event(user_id=3, device_id=7, referrer="twitter", host="eczachly.com", url="/signup", event_time="2023-01-01")
)
```

### Caching Lab Code

```sql
-- For this code to run, your kernel may need to change to
-- spylon-kernel to get spark data
import org.apache.spark.sql.functions._
import org.apache.spark.storage.StorageLevel

spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")
spark.conf.set("spark.sql.analyzer.failAmbiguousSelfJoin", "false")
spark.conf.set("spark.sql.shuffle.partitions", "4")

val users = spark.read.option("header", "true")
                      .option("inferSchema", "true")
                      .csv("/home/iceberg/data/events.csv")
                      .where($"user_id".isNotNull)

users.createOrReplaceTempView("events")

val executionDate = "2023-01-01"

/*************
    Caching here should be < 5 GBs or used for broadcast join
    You need to tune executor memory otherwise it'll spill to disk and be slow
    Don't really try using any of the other storage level besides MEMORY_ONLY
*************/
val eventsAggregated = spark.sql(f"""
    SELECT user_id,
           device_id
           COUNT(1) AS event_counts,
           COLLECT_LIST(DISTINCT host) AS host_array
    FROM events
    GROUP BY 1, 2
""")
/*************
    Psst... See what happens when you add .cache() at the end like so:
    
    val eventsAggregated = spark.sql(f"""
        SELECT user_id,
            device_id
            COUNT(1) AS event_counts,
            COLLECT_LIST(DISTINCT host) AS host_array
        FROM events
        GROUP BY 1, 2
    """).cache()

    .cache()  is the same thing as .cache(StorageLevel.MEMORY_ONLY)
*************/

spark.sql(f"""
    CREATE TABLE IF NOT EXISTS bootcamp.events_aggregated_staging(
        user_id BIGINT,
        device_id BIGINT,
        event_counts BIGINT,
        host_array ARRAY<STRING>
    )
    PARTITIONED BY (ds STRING)
""")

-- Take eventsAggregated and join it back to itself
val usersAndDevices = users
    .join(eventsAggregated, eventsAggregated("user_id") === users("user_id"))
    
    -- Aggregate up
    .groupBy(users("user_id"))
    .agg(
        users("user_id"),
        max(eventsAggregated("event_counts")).as("total_hits"),
        collect_list(eventsAggregated("device_id")).as("devices")
    )

val devicesOnEvents = devices
    .join(eventsAggregated, devices("device_id") === eventsAggregated("device_id"))
    .groupBy(devices("device_id"), devices("device_type"))
    .agg(
        devices("device_id"),
        devices("device_type"),
        collect_list(eventsAggregated("user_id")).as("users")
    )

devicesOnEvents.explain()
usersAndDevices.explain()

devicesOnEvents.take(1)
usersAndDevices.take(1)

```

### Persist

```sql
eventsAggregated.write.mode("overwrite").saveAsTable("bootcamp.events_aggregated_staging")
```

### Bucket Joins

```sql
-- In Python use: from pyspark.sql.functions import 
-- broadcast, split, lit
import org.apache.spark.sql.functions.{broadcast, split, lit}

-- Both have match_id as a shared key, so it will be our JOIN key
val matchesBucketed = spark.read.option("header", "true")
                        .option("inferSchema", "true")
                        .csv("/home/iceberg/data/matches.csv")

val matchDetailsBucketed = spark.read.option("header", "true")
                        .option("inferSchema", "true")
                        .csv("/home/iceberg/data/match_details.csv")

spark.sql("""DROP TABLE IF EXISTS bootcamp.matches_bucketed""")
val bucketedDDL = """
CREATE TABLE IF NOT EXISTS bootcamp.matches_bucketed (
    match_id STRING,
    is_team_gone BOOLEAN,
    playlist_id STRING,
    completion_date TIMESTAMP
)
USING iceberg

-- Partitioning on date and buckets
PARTITIONED BY (completion_date, bucket(16, match_id))
"""
spark.sql(bucketedDDL)

-- Write out the data into the buckets
matchesBucketed.select(
    $"match_id", $"is_team_game", $"playlist_id", $"completion_date"
)
    -- Overwrite gives errors, but append works
    .write.mode("append")
    .partitionBy("completion_date")

   -- Create 16 buckets by match_id and save the table
   .bucketBy(16, "match_id").saveAsTable("bootcamp.matches_bucketed")

val bucketedDetailsDDL = """
CREATE TABLE IF NOT EXISTS bootcamp.match_details_bucketed (
    match_id STRING,
    player_gamertag STRING,
    player_total_kills INTEGER,
    player_total_deaths INTEGER
)
USING iceberg
PARTITIONED BY (bucket(16, match_id));
"""

spark.sql(bucketedDetailsDDL)

matchDetailsBucketed.select(
    $"match_id", $"player_gamertag", $"player_total_kills",$"player_total_deaths")
    .write.mode("append")
    .bucketBy(16, "match_id").saveAsTable("bootcamp.match_details_bucketed")

/*************
    The data is not very big, so putting "-1" as the 
    second argument disables a broadcast join.
    We are trying to force a bucket join here to see the 
    difference, it would default to a broadcast join 
    otherwise     
*************/
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")

-- The unbucketed CSV files
matchesBucketed.createOrReplaceTempView("matches")
matchDetailsBucketed.createOrReplaceTempView("match_details")

-- This query is querying the Iceberg
spark.sql("""
    SELECT * FROM bootcamp.match_details_bucketed mdb JOIN bootcamp.matches_bucketed md
    ON mdb.match_id = md.match_id
    AND md.completion_date = DATE('2016-01-01')
""").explain()

spark.sql("""
    SELECT * FROM match_details mdb JOIN matches md ON mdb.match_id = md.match_id
""").explain()

```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What tool is necessary to ensure the Spark setup works correctly?
- What is the purpose of running Docker compose up in the Apache Spark setup?
- What is a common use of user-defined functions (UDFs) in Spark?
- How does the Scala 'Option' type enhance data serialization in Spark?
- In the context of the dataset API in Spark, what does wrapping a data type in 'Option' signify?
- Why is caching used in Spark, and when does it provide benefits?
- What does calling '.cache' in Spark effectively do?
- Why might you choose to use a 'bucket join' over a 'broadcast join' in Spark?
- What distinguishes the handling of user-defined functions (UDFs) in the data frame API from the data set API in Spark?
- What is a key advantage of using bucket joins in Spark?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

For the Spark setup, Docker Desktop is needed to run ad manage the containerized environment. `docker compose up` is used to set up and run the necessary Docker containers required for the Apache Spark lab environment. User-defined functions (UDFs) are used in Spark to apply custom functions to data, such as transforming or manipulating columns.

The Scala 'Option' type allows nullable fields to be wrapped, which helps manage null values during serialization. Wrapping a data type in 'Option' in Scala indicates the value is nullable. Calling `.cache` will cache the data in memory to speed up its reuse in future operations, which provides performance benefits when that data is accessed multiple times. Bucket joins can significantly reduce data shuffling, which improves the efficiency of joining large datasets.
