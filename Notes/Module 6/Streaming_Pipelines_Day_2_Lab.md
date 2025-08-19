# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Streaming Pipelines

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Kafka, Postgres, Spark Integrations and Parallelism Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Creating a New Window Job**  | - Creates another entry point  <br> &emsp;• [Create a New Window Job](#create-a-new-window-job)<br>- In aggregation_job.py, change the table_name to "process_events_kafka" in the aggregation job|
| **Group Window Error & Fix**  | - "A group window expects a time attribute for grouping in a stream environment" <br> &emsp;• In aggregation_job.py, we have event_timestamp in the CREATE TABLE function, but it is a VARCHAR <br> &emsp;• Add the pattern `pattern = "yyy-MM-dd HH:mm:ss`<br> &emsp;• Create a new column called window_timestamp <br> &emsp;&emsp;• `window_timestamp AS TO_TIMESTAMP(event_timestamp, '{pattern}')` <br>- Under log_aggregation:<br> &emsp;• [Adjust Tumble Code](#adjust-tumble-job) <br> &emsp;• Remember to `make up`/`make down` when you adjust the code to get your most recent changes<br> &emsp;• `make aggregation_job` again<br>- If you are still getting errors, try adjusting `'scan.startup.mode' = 'latest-offset'` and `'properties.auto.offset.reset' = 'latest'`<br>- For persistent "...group window expects..." errors, try adding a watermark in create_processed_events_source_kafka<br> &emsp;• `WATERMARK FOR window_timestamp AS window_timestamp - INTERVAL '15' SECOND` |
| **How Tumbling Works**  | - You define a window <br> &emsp;• The window_timestamp can be based on processing time or the event time<br> &emsp;&emsp;• Usually, you want to process on the event time <br>- Group the windows together with a `GROUP BY` <br>- Aggregates every N minutes under ideal conditions|
| **Window Jobs are Complex**  | - Window jobs are completed in 2 steps<br> &emsp;1. Read in the data <br> &emsp;2. Aggregate the group window<br>- Watermarks are useful here because you are grouping data, and it needs to be ordered |
| **Add Processed Events Table to SQL**  | - [Create Table Code](#create-sql-tables) |
| **Running Aggregations in Flink vs Spark vs Batch vs Streaming**  | - Remember, think about what sort of aggregation you are doing over what time frame <br> &emsp;• Flink is nice for this lab because it's a 5 minute aggregation <br> &emsp;• If you have a group by that's an hour or longer, batch can be better<br> &emsp;• You can do a tumble window of ~30 minutes or something, then do another aggregation in Spark for however many hours you want to do<br>- Once the window closes, it writes out the data and persists to disk at that point |

### Create a New Window Job

```Makefile
## Submit the Flink jobs
job:
    docker compose exec jobmanager ./bin/flink run -py /opt/src/job/start_job.py --pyFiles /opt/src -d

window_job:
    docker compose exec jobmanager ./bin/flink run -py /opt/src/job/app.py --pyFiles /opt/src -d
```

### Adjust Tumble Job

```JavaScript
...

// Opens a window every 5 minutes
t_env.from_path(source_table).window(
    Tumble.over(lit(5).minutes).on(col("window_timestamp")).alias("w")
    // Change to "window_timestamp" from "event_timestamp"
).group_by(
    // Creates windows based on the host and the time in 
    // 5 minute chunks 
    col("w"),
    col("host")
) \
    .select(
        col("w").start.alias("event_hour"),
        col("host"),
        col("host").count.alias("num_hits")
    ) \
    .execute_insert(aggregated_table)

t_env.from_path(source_table).window(
    // You have to change event_timestamp to window_timestamp here, too!
    Tumble.over(lit(5).minutes).on(col("window_timestamp")).alias("w")
).group_by(
    col("w"),
    col("host"),
    col("referrer")
) \
    .select(
        col("w").start.alias("event_hour"),
        col("host"),
        col("referrer"),
        col("host").count.alias("num_hits")
    ) \
        .execute_insert(aggregated_sink_table) \
        .wait()

...
```

### Create SQL Tables

```sql
CREATE TABLE processed_events_aggregated (
    event_hour TIMESTAMP(3),
    host VARCHAR,
    num_hits BIGINT
);

CREATE TABLE processed_events_aggregated_source (
    event_hour TIMESTAMP(3),
    host VARCHAR,
    referrer VARCHAR,
    num_hits BIGINT
);
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What tool is primarily responsible for dumping the processed data into Kafka in the lab exercises?
- Why is setting a watermark important in Flink for processing streaming data?
- What is a key difference between using a streaming engine like Flink versus a batch processing tool like Spark?
- Why might you want to change the Kafka data offset from 'earliest' to 'latest' in a streaming job?
- In the context of this lab, why might setting a parallelism level be beneficial?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

Flink is used in the lab exercises to handle data streaming jobs and to dump the processed data into Kafka. Setting a watermark is crucial for managing out-of-order data and ensuring proper processing in the correct order in a streaming environment. Flink is designed for low-latency, real-time data processing, making it more suitable for continuous data streams compared to Spark's batch-oriented processing.

Changing to "latest" ensures that only new incoming data is processed, which avoids delays caused by processing large volumes of historical data. Setting parallelism allows for distributing the workload across multiple tasks, speeding up data processing by utilizing available resources more efficiently.
