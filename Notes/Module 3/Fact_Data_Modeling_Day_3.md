# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Fact Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Minimizing Shuffle and Reducing Facts Day 3 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Minimizing Shuffle**  | - Why should shuffle be minimized?<br> &emsp;• Shuffle is the bottleneck for parallelism <br> &emsp;&emsp;• If you have a pipeline that doesn't use shuffle, it can be as parallel as you want it to be because you don't need a specific chunk of data to be on one machine <br> &emsp;• Big data leverages parallelism as much as it can <br> &emsp;• Some steps are inherently less "parallelizable" than others<br> &emsp;&emsp;• The more paralelism we can have, the more effectively we can crunch big data <br> &emsp;&emsp;&emsp;• We can use more machines this way with less bottlenecks |
| **Highly Parallelizable Queries**  | - **Extremely Parallel**<br> &emsp;• `SELECT`<br> &emsp;&emsp;• As long as your `SELECT` does not use a window function <br> &emsp;• `WHERE`<br> &emsp;• `FROM` <br> &emsp;• Can be infinitely scalable<br> &emsp;• ***You don't have to have a specific chunk of data on a specific machine for these queries*** <br> &emsp;&emsp;• The job should *come back instantly* <br> &emsp;&emsp;• The job should have *no shuffle*<br> &emsp;&emsp;• The job should be *cheap*<br><br>- **Kinda Parallel**<br> &emsp;• `GROUP BY`<br> &emsp;• `JOIN`<br> &emsp;• `HAVING` <br> &emsp;• In order to do the right aggregation, all of the rows for that key need to be on one machine in order to correctly count them <br> &emsp;&emsp;• ***Shuffle happens when you need to have all the data from a specific key on a specific machine*** <br> &emsp;• **Example** <br> &emsp;&emsp;• If we have a billion machines, we would pass all of the data to 200 machines (the default number) based on the key <br> &emsp;&emsp;&emsp;• If this key is the user_id (an integer), you would divide the user_id by 200 to find the remainder to find the machine it goes to <br> &emsp;&emsp;&emsp;• If the user_id is 207, it would go to the 7th machine <br> &emsp;&emsp;&emsp;• If the user_id is 402, it goes to the 2nd machine<br>&emsp;• In the case of `JOIN`, all of the keys are on the left side and all of the keys on the right side <br>&emsp;&emsp;• They keys on the left and right side all have to be pushed to one machine <br>&emsp;&emsp;&emsp;• This is one partition in your shuffle partitions <br>&emsp;&emsp;&emsp;• After this, the sides are compared to see if they match<br>&emsp;&emsp;&emsp;&emsp;• If so, it keeps that record <br>&emsp;&emsp;&emsp;&emsp;• If they don't match and it's an `INNER JOIN`, it chucks it <br>&emsp;• `HAVING` is technically as parallel as `SELECT`, `FROM`, and `WHERE`, but it's a step after `GROUP BY` so it can only be applied *after* shuffle<br><br>- **Painfully *Not* Parallel**<br> &emsp;• `ORDER BY` <br>&emsp;• If `ORDER BY` is used at the end of the query instead of as a window funciton<br>&emsp;&emsp;• `ORDER BY`s in a window function don't do a global sort <br>&emsp;&emsp;&emsp;• It **can** if you don't put any `PARTITION BY` or if you are using a `RANK` without a `PARTITION BY`<br>&emsp;&emsp;&emsp;&emsp;• This will give you the same parallelism problem <br>&emsp;• It should be used at the end after things are aggregated to a smaller number <br><br>- ***How the data is structured determines which of these key words you use*** <br>&emsp;• This is important to consider when you are thinking about your fact data modeling |
| **Making `GROUP BY` More Efficient**  | 1. Give `GROUP BY` buckets and guarantees<br> &emsp;• You can pre-shuffle the data for Spark <br> &emsp;• Bucket based on a key (usually a high-cardinality integer field) <br> &emsp;&emsp;• Completes the modulus grouping when you write the data out<br> &emsp;&emsp;&emsp;• This way, when you use `GROUP BY`, you don't have to shuffle because the buckets are already set <br>2. ***Reduce the data volume as much as you can*** |
| **Reduced Fact Data Modeling Gives You Superpowers** | - **Fact data** often has the following schema: <br> &emsp;• user_id, event_time, action, date_partition<br> &emsp;• Very high volume, 1 row per event <br> &emsp;• [Example Fact Data](#example-fact-data) <br> &emsp;&emsp;• Answers very specific questions <br> &emsp;&emsp;• For use with very small time frames<br> &emsp;&emsp;&emsp;• If the data gets too large, it gets unweildy <br><br>- **Daily aggregated data** often has this schema <br> &emsp;• user_id, action_count, date_partition <br> &emsp;• Medium sized volume, 1 row per user per day <br> &emsp;• [Example Daily Aggregated Data](#example-daily-aggregated-data)<br> &emsp;&emsp;• Gives you a longer time horizon <br> &emsp;&emsp;• Your partition on this table is date with a sub-partition on metric_name<br> &emsp;&emsp;• You can still join this table with SCDs <br> &emsp;&emsp;• You can still do aggregates at the higher level by bringing in other dimensions<br> &emsp;&emsp;• These queries do take time to work with (sometimes days) <br> &emsp;&emsp;• Also called a **metric repository** <br><br>- **Reduced fact data** takes this one step further <br> &emsp;• user_id, action_count Array, month_start_partition / year_start_partition <br> &emsp;• Low volume, 1 row per user per month/year <br> &emsp;• **As the data gets smaller, you lose some of the flexibility around what kind of analytics you can do on it**<br> &emsp;• [Example Long-Array Metrics](#example-long-array-metrics) <br> &emsp;&emsp;• 1 row per month with a value array <br> &emsp;&emsp;• Looks at all the metrics in the month <br> &emsp;&emsp;• **This is not a monthly aggregate**<br> &emsp;• Daily dates are stored as an offset of **month_start** / **year_start**<br> &emsp;&emsp;• First index is for date month_start + zero days<br> &emsp;&emsp;• Last index is for date month_start + array_length - 1 <br> &emsp;• Dimensional joins get weird if you want things to stay performant<br> &emsp;&emsp;• Your SCD accuracy becomes the same as month_start or year_start <br> &emsp;&emsp;&emsp;• You give up 100% accurate SCD tracking for massively increased performance <br> &emsp;&emsp;• You need to pick snapshots in time (month start, month end, or both) and treat the dimensions as fixed <br> &emsp;• Impact of this kind of analysis <br> &emsp;&emsp;• Multi-year analyses took hours instead of weeks <br> &emsp;&emsp;• Unlocked "dacades-long slow burn" analyses at Facebook <br> &emsp;• Allowed for fast correlation analysis between user-level metrics and dimensions|

### Example Fact Data

| user_id             | event_time            | action            | date            | other_properties            |
|---------------------|------------------|------------------|------------------|------------------|
| 3 | 2023-07-08T11:00:31Z | like | 2023-07-08 | {"os": "Android", "post": 1414} |
| 3 | 2023-07-09T09:33:34Z | comment | 2023-07-09 | {"os": "iphone", "post": 111} |
| 3 | 2023-07-10T03:33:11Z | comment | 2023-07-10 | {"os": "Android", "post": 3434} |

### Example Daily Aggregated Data

| user_id             | metric_name            |date            | other_properties            |
|---------------------|------------------|------------------|------------------|
| 3 | likes_given | 2023-07-08 | 34 |
| 3 | likes_given | 2023-07-09 | 1 |
| 3 | likes_given | 2023-07-10 | 3 |

### Example Long-Array Metrics

| user_id             | metric_name            |month_start            | value_array            |
|---------------------|------------------|------------------|------------------|
| 3 | likes_given | 2023-07-01 | [34, 3, 3, 4, 5, 6, 7, 7, 3, 3, 4, 2, 1, 5, 6, 3, 2, 1, 5, 2, 33, 3, 4, 5, 7, 8, 3, 4, 9] |
| 3 | likes_given | 2023-08-01 | [9, 3, 3, 4, 5, 0, 7, 0, 3, 3, 4, 2, 1, 5, 6, 3, 2, 10, 5, 2, 46, 3, 42, 5, 7, 3, 3, 4, 9] |
| 3 | likes_given | 2023-09-01 | [17, 3, 0, 4, 1, 6, 2, 7, 3, 10, 4, 2, 1, 0, 6, 3, 2, 1, 5, 2, 33, 3, 4, 5, 7, 8, 3, 4, 9] |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What trade-off is associated with using reduced fact data models?
- Why are SELECT, FROM, and WHERE considered infinitely scalable in SQL queries?
- What is a drawback of using the ORDER BY keyword in distributed computing?
- What is a primary reason to minimize shuffle in data processing pipelines?
- How does bucketing help in reducing the shuffle in data processing?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

Reduced fact data models decrease data volume and processing time, but limit the flexibility for performing complex queries and detailed analyses. `SELECT`, `FROM`, and `WHERE` are considered infinitely scalable because they do not require specific data chunks to be on a single machine, which allows for maximum parallelism. `ORDER BY` is the least parallelizable because it requires all data to be transferred to a single machine for global sorting, which negates parallel processing benefits.

Shuffle should be minimized because it creates a bottleneck for parallelism, which can hinder the effective use of multiple machines for big data processing. Bucketing pre-shuffles the data so the operations like `GROUP BY` can rely on this pre-organized data, thereby reducing the need for shuffle during processing.
