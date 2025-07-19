# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Fact Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Core Concepts, Deduplication Day 1 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Fact Data**  | - Can bery large compared to dimensional data <br> &emsp;• Event logging, high volume <br>- A fact can be thought of as **something that happened or occurred**<br> &emsp;• A user logs in to an app <br> &emsp;• A transaction is made <br> &emsp;• You run a mile with your fitbit <br><br>- Are not slowly changing, which makes them easier to model than dimensions in some respects<br>- Aggregations can be done in layers |
| **What Makes Fact Modeling Hard?**  | - Fact data is usually 10-100x the volume of dimension data <br> &emsp;• You can roughly predict how the fact data will balloon by examining how many actions are taken per dimension <br>- Fact data can need a lot of context for effective analysis <br>- Duplicates in facts are way more common than in dimensional data |
| **Fact Modeling**  | - Normalization vs Denormalization <br> &emsp;• Normalized facts don't have any dimensional attributes, just IDs to join to get that information<br> &emsp;&emsp;• The smaller the scale, the better normalization will be for your purposes <br> &emsp;• Denormalized facts bring in some dimensional attributes for quicker analysis at the cost of more storage <br>- Both have a place in the world! <br><br>- Think of facts as a who, what, when, where, or a how <br> &emsp;• "Who" fields are usually pushed out as IDs (this user clicked this button)<br> &emsp;&emsp;• In this instance, we only hold the user_id, not the entire user object <br> &emsp;• "Where" fields <br> &emsp;&emsp;• Most likely modeled out like Who with "IDs" to join, but more likely to bring in dimensions, especially if they're high cardinality like "device_id" <br> &emsp;• "How" fields <br> &emsp;&emsp;• How fields are very similar to "Where" fields. <br> &emsp;&emsp;&emsp;• i.e. He used an iPhone to make this click <br> &emsp;• "What" fields are fundamentally part of the nature of the fact <br> &emsp;&emsp;• In the notification world - "generated", "sent", "clicked", "delivered" <br> &emsp;• "When" fields are fundamentally part of the nature of the act <br> &emsp;&emsp;• Mostly an "event_timestamp" field or "event_date" |
| **Raw Logs vs Fact Data**  | - Fact data and raw logs are not the same thing <br> &emsp;• Raw logs <br> &emsp;&emsp;• Ugly schemas designed for online systems <br> &emsp;&emsp;• Potentially contains duplicates and other quality errors <br> &emsp;&emsp;•  Usually shorter retention<br> &emsp;• Fact data <br> &emsp;&emsp;• Nice column names <br> &emsp;&emsp;• Quality guarantees like uniqueness, not null, etc <br> &emsp;&emsp;• Longer retention <br> &emsp;&emsp;• Should be as trustworthy as the raw logs|
| **Fact Data Should...**  | - Be generally smaller than raw logs <br>- Should parse out hard-to-understand columns <br>- Fact datasets should have quality guarantees <br> &emsp;• If they didn't, analysis would just go to the raw logs!<br> &emsp;• WHAT, WHO, and WHEN fields should never be NULL. If they're not there, you can't analyze the data |
| **Broadcast JOINs**  | - **Broadcast JOIN** in Spark is a way you can do a `JOIN` that is very efficient<br> &emsp;• but the only way it works is if one side of the `JOIN` is less than 5-6 GB |
| **When To Model In Dimensions**  | - Denormalizing and logging data ahead of time can reduce the need for `JOIN`s |
| **How Data Logging Fits Into Fact Data**  | - Logging brings in all the critical context for your data <br> &emsp;• Usually done in collaboration with online systems engineers<br> &emsp;• Should give you all the columns you need<br> &emsp;• Include the IDs in the table so folks can join in the dimensions they need on the ID <br>- Don't log everything! <br> &emsp;• Log only what you really need <br>- Logging should conform to values specified by the online teams<br> &emsp;• Thrift is what is used at Airbnb and Netflix for this  |
| **Potential Options When Working with High Volume Fact Data**  | - Sampling <br> &emsp;• Doesn't work for all use cases <br> &emsp;• Works best for metric-driven use-cases where imprecision isn't an issue <br>- Bucketing<br> &emsp;• Buckets usually happen on the WHO IDs<br> &emsp;• Fact data can be bucketed by one of the important dimensions (usually user)<br> &emsp;• Bucket joins can be much faster than shuffle joins <br> &emsp;• Sorted-merge Bucket (SMB) joins can do joins without Shuffle at all! |
| **How Long Should You Hold Onto Fact Data**  | - High volumes make fact data much more costly to hold onto for a long time<br>- Big Tech's approach: <br> &emsp;• Any fact tables <10 TB, retention didn't matter much <br> &emsp;&emsp;• Anonymization of facts usually happened after 60-90 days and the data would be moved to a new table with the PII stripped<br> &emsp;• Any fact tables >100 TB had a *very short retention* (~14 days or less) |
| **Deduplication of Fact Data**  | - Facts can often be duplicated <br> &emsp;• i.e. You can click a notification multiple times <br>- How do you pick the right window for deduplication? <br> &emsp;• No duplicates in a day? An hour? A week?<br> &emsp;• Looking at distributions of duplicates here is a good idea <br>- Intraday deduping options <br> &emsp;• Streaming <br> &emsp;• Microbatch<br> &emsp;&emsp;• i.e. on an hourly basis |
| **Streaming**  | - **Streaming** allows you to capture most duplicates in a very efficient manner <br> &emsp;• Windowing matters here  <br> &emsp;• Entire day duplicates can be harder for streaming because it needs to hold onto such a big window of memory  <br> &emsp;• A large memory of duplicates usually happen within a short time of the first event  <br> &emsp;• 15-minute to hourly windows are a sweet spot <br> &emsp;&emsp;• A large majority of the duplicates happen in a short window after the first event <br>&emsp;&emsp;• The smaller your duplication window, the better option streaming is |
| **Microbatch**  | - Microbatch dedupe example <br> &emsp;• Dedupe each hour with `GROUP BY` <br> &emsp;• Use `SUM` and `COUNT` to aggregate duplicates, use `COLLECT_LIST` to collect metadata about the duplicates that might be different! <br> &emsp;&emsp;Step 1. [Hourly Microbatch Example](#hourly-microbatch-example) <br> &emsp;&emsp;Step 2. `FULL OUTER JOIN` between hours 0 & 1, 2 & 3, etc <br> &emsp;&emsp;&emsp;• Eliminates duplicates that are across hours<br> &emsp;&emsp;&emsp;• [Microbatch Step Two](#microbatch-step-two)  |

### Hourly Microbatch Example

```sql

-- Gets all of the information for the hour and aggregates down
-- Eliminates all the duplicates in an hour
SELECT
    product_id,
    event_type,
    MIN(event_timestamp_epoch) AS min_event_timestamp_epoch,
    MAX(event_timestamp_epoch) AS max_event_timestamp_epoch,
    MAP_FROM_ARRAYS(
        COLLECT_LIST(event_location),
        COLLECT_LIST(event_timestamp_epoch)
    ) AS event_locations
FROM event_source
GROUP BY product_id, event_type
```

### Microbatch Step Two

```sql

-- Use left.value + right.value to keep duplicates aggregation
-- correctly counting or CONCAT to build a continuous list
WITH earlier AS (
    SELECT * FROM hourly_deduped_source
    WHERE {ds_str} AND hour = {earlier_hour} AND product_name = {product_name}
),
    later AS (
        SELECT * FROM hourly_deduped_source
        WHERE {ds_str} AND hour = {later_hour} AND product_name = {product_name}
    )

SELECT
    COALESCE(e.product_id, l.product_id) AS product_id,
    COALESCE(e.event_type, l.event_type) AS event_type,
    COALESCE(e.min_event_timestamp_epoch, l.min_event_timestamp_epoch) AS min_event_timestamp_epoch,
    COALESCE(e.max_event_timestamp_epoch, l.max_event_timestamp_epoch) AS max_event_timestamp_epoch,
    CONCAT(e.event_locations, l.event_locations) AS event_locations
FROM earleir e
    FULL OUTER JOIN later l
        ON e.product_id = l.product_id
        AND e.event_type = l.event_type

```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- Why is fact data typically much larger than dimensional data?
- What is the main challenge of working with fact data according to the lecture?
- How are 'facts' characterized in the context of data modeling?
- What is a significant advantage of denormalized fact data?
- Why is uniformity in time zones important in fact data logging?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

Fact data records every event a user performs, such as clicks and interactions. Fact data is significantly larger because of this, which results in a high volume of records compared to dimensional data. Efficient deduplication is crucial for fact data to prevent duplicate records, which can distort metrics and analytics outcomes.

In data modeling, facts are seen as unchangeable, logged events that provide a record of what occurred at a specific point in time. Denormalized fact data includes additional context alongside facts, which allows for easier grouping and analysis without complex `JOIN` operations. Uniform timezones, preferably UTC, ensure consistent timestamping across regions, facilitating accurate temporal analysis of event data.
