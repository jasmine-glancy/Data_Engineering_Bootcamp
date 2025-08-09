# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Apache Spark

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Hands-On for Broadcast and Hash Joins Day 1 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Pro Tip**  | - The `.explain()` method helps you see an execution plan<br> &emsp;• Goes to the most indented thing first (read from the bottom up)|
| **Setting up Spark**  | - Spark is managed by the SparkSession, so you want to build this and create an app name <br> &emsp;• [Setting up the SparkSession](#setting-up-the-sparksession) |
| **Collect() and OOM Errors**  | - `df.join(df, lit(1) == lit(1)).collect()` <br> &emsp;• Blows out the data frame<br> &emsp;• `collect()` causes an OutOfMemory error: Java heap space<br> &emsp;&emsp;• Happens when the query brings back too much data<br> &emsp;&emsp;• The kernel needs to be restarted when Spark errors out <br>- `df.join(df, lit(1) == lit(1)).take(5)`<br> &emsp;• A better option<br>- **If you call `.collect()`, be sure you filter or aggregate it down, first!**<br> &emsp;• Prioritize using `.take()` and `.show()` <br> &emsp;• Pulling the whole dataset into the driver is bad practice<br> &emsp;&emsp;• Only use `.collect()` if you know for sure the dataset has been aggregated down|
| **Sorting Options**  | - `sorted = df.repartition(10, col("event_date"))`<br> &emsp;• However many partitions we had before, we are going to have 10 partitions split up by date <br>- `.sortWithinPartitions(col("event_date"), col("host"), col("browser_family))` <br> &emsp;• If you go with `.sort(col("event_date"), col("host"), col("browser_family))` instead: <br> &emsp;&emsp;• They pull different information and are very different at scale<br> &emsp;&emsp;• Make sure you understand the API to understand why they are different at scale<br> &emsp;&emsp;• `.sortWithinPartitions` will take the 10 partitions that you have, look at all the data in those partitions, and sort all of them locally within those partitions <br> &emsp;&emsp;• `.sort` gives you a global sort (sorts data as far back as you can go)<br> &emsp;&emsp;&emsp;• Global sorts are very slow if you have more than 20 GB of data<br> &emsp;&emsp;&emsp;&emsp;• ***If you are going to do a global sort, you have to pass the data through one executor because it's the only way you can guarantee the data is globally sorted***<br> &emsp;&emsp;&emsp;• Running `.explain()` on `.sort` shows an additional line, `Exchange rangepartitioning(event_date#31 ASC NULLS FIRST, host#22 ASC NULLS FIRST, browser_family#19 ASC NULLS FIRST, 200), ENSURE_REQUREMENTS, [plan_id=313]` that is **painful** at scale<br>- Every time you see the word `Exchange` in a query plan, think shuffle! Shuffle and exchange are synonyms<br><br>**TL;DR:** At scale, you want to use `.sortWithinPartitions`|
| **Setup Code**  | - [Drop the Table If It Exists](#drop-the-table-if-it-exists)<br> - [Create Events Table](#create-events-table) <br>- [Create Events Sorted Table](#create-events-sorted-table) <br>- [Create Events Unsorted Table](#create-events-unsorted-table) <br>- [Sort and Repartition](#sort-and-repartition) <br>- [Example Query](#example-query)|
| **Writing Data Out**  | - When you are writing out your data, you want to start with your lowest cardinality and work toward the highest cardinality  <br> &emsp;• In this case, event_date will be the lowest cardinality because there's only going to be a few hundred records <br> &emsp;• Next browser<br> &emsp;• After that, host|

### Setting Up the SparkSession

```sql
from pyspark.sql import SparkSession
from pyspark.sql.functions import expr, col

-- CamelCase because Spark is a JVM library
spark = SparkSession.builder.appName("Jupyter").getOrCreate()

df = spark.read.option("header", "true") \
          .csv("/home/iceberg/data/event_data.csv") \
          .withColumn("event_date", expr("DATE_TRUNC('day', event_time)"))

-- df.collect() can cause OOM
df.show()

```

### Drop the Table If It Exists

```sql
DROP TABLE IF EXISTS bootcamp.events
```

### Create Events Table

```sql
CREATE TABLE IF NOT EXISTS bootcamp.events (
    url STRING,
    referrer STRING,
    browser_family STRING,
    os_family STRING,
    device_family STRING,
    host STRING,
    event_time TIMESTAMP,
    evemt_date DATE
)
USING iceberg

-- You can also partition by days, hours, etc
PARTITIONED BY (event_date);
```

### Create Events Sorted Table

```sql
CREATE TABLE IF NOT EXISTS bootcamp.events_sorted (
    url STRING,
    referrer STRING,
    browser_family STRING,
    os_family STRING,
    device_family STRING,
    host STRING,
    event_time TIMESTAMP,
    evemt_date DATE
)
USING iceberg;
PARTITIONED BY (event_date);
```

### Create Events Unsorted Table

```sql
CREATE TABLE IF NOT EXISTS bootcamp.events_unsorted (
    url STRING,
    referrer STRING,
    browser_family STRING,
    os_family STRING,
    device_family STRING,
    host STRING,
    event_time TIMESTAMP,
    evemt_date DATE
)
USING iceberg;
PARTITIONED BY (event_date);
```

### Sort and Repartition

```sql
start_df = df.repartition(4, col("event_date")).withColumn("event_time", col("event_time").cast("timestamp")) \

first_sort_df = start_df.sortWithinPartitions(col("event_date"), col("browser_family"), col("host"))

sorted = df.repartition(10, col("event_date")) \
           .sortWithinPartitions(col("event_date"))

start_df.write.mode("overwrite").saveAsTable("bootcamp.event_unsorted")
first_sort_df.write.mode("overwrite").saveAsTable("bootcamp.events_sorted")

```

### Example Query

```sql
-- How you can see the size of a dataset 
SELECT SUM(file_size_in_bytes) AS size, COUNT(1) AS num_files, 'sorted'
FROM demo.bootcamp.events_sorted.files

UNION ALL
SELECT SUM(file_size_in_bytes) AS size, COUNT(1) AS num_files, 'unsorted'
FROM demo.bootcamp.events_unsorted.files
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What do you need to have installed and running to complete the Apache Spark lab?
- Why is it important to limit data before using the .collect method in Spark?
- In Spark, what is the difference between 'sort' and 'sort within partitions'?
- What does the 'explain' method do in Apache Spark?
- Why is sorting data important when writing it out using Iceberg?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

For this lab, Docker Desktop is required to set up the necessary environment for running Apache Spark. It's crucial to limit data before using `.collect` to prevent the driver from running out of memory when handling large datasets. `.sort` sorts the entire dataset globally, whereas `.sortWithinPartiotions` sorts each partition independently. This makes `.sortWithinPartiotions` faster and more efficient for large-scale data processing.

The `.explain` method provides insights into the execution plan of a query. This can help you understand data processing and optimization steps in Spark. Sorting data helps in improving compression efficiency through run length encoding, leading to smaller data sizes and more efficient storage.
