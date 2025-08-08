# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Apache Spark

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Hands-On for Broadcast and Hash Joins Day 1 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Setting up Spark**  | - Spark is managed by the SparkSession, so you want to build this and create an app name <br> &emsp;• [Setting up the SparkSession](#setting-up-the-sparksession) |
| **Collect() and OOM Errors**  | - `df.join(df, lit(1) == lit(1)).collect()` <br> &emsp;• Blows out the data frame<br> &emsp;• `collect()` causes an OutOfMemory error: Java heap space<br> &emsp;&emsp;• Happens when the query brings back too much data<br> &emsp;&emsp;• The kernel needs to be restarted when Spark errors out <br>- `df.join(df, lit(1) == lit(1)).take(5)`<br> &emsp;• A better option<br>- **If you call `.collect()`, be sure you filter or aggregate it down, first!**<br> &emsp;• Prioritize using `.take()` and `.show()` <br> &emsp;• Pulling the whole dataset into the driver is bad practice<br> &emsp;&emsp;• Only use `.collect()` if you know for sure the dataset has been aggregated down|
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |

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

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx