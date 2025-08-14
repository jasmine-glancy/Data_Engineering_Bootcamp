# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Streaming Pipelines

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Mastering Streaming and Real-time Pipelines Day 1 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Streaming Pipelines**  | - Streaming pipelines process data in a low-latency way <br>- **Streaming vs near real time vs real time** <br> &emsp;• Streaming (or continuous)<br> &emsp;&emsp;• Data is processed as it is generated<br> &emsp;&emsp;• Example: Flink <br> &emsp;• Near real-time<br> &emsp;&emsp;• Data is processed in small batches every few minutes<br> &emsp;&emsp;• Example: Spark Structured Streaming<br> &emsp;• Real-time and streaming are often synonymous, but not always!<br> &emsp;• Less technical people may think real-time and batch are synonymous <br> &emsp;• **Microbatching** is synonymous with near real-time. Data is processed in small batches |
| **Real-time From Stakeholder POV**  | - Rarely means streaming <br>- Usually means low-latency or predictable refresh rate |
| **When Streaming Should Be Used**  | - Considerations <br> &emsp;• Skills on the team<br> &emsp;• What is the incremental benefit?<br> &emsp;• Homogeneity of your pipelines<br> &emsp;• The tradeoff between daily batch, hourly batch, microbatch, and streaming<br> &emsp;• How should data quality be inserted<br> &emsp;&emsp;• Batch pipelines have easier DQ paths |
| **Streaming-only Use Cases**  | - **Key: *Low latency makes or breaks the use case*** <br>- Examples: <br> &emsp;• Detecting fraud, preventing bad behavior <br> &emsp;• High-frequency trading <br> &emsp;• Live event processing |
| **Gray-area Use Cases**  | - Data that is served to customers<br>- Reducing the latency of upstream master data <br> &emsp;• Notifications dataset had a 9 hour after midnight latency<br> &emsp;• Micro batch cut to 1 hour |
| **No-go Streaming Use Cases**  | - Batch should be used instead <br>- Ask the question <br> &emsp;• What is the incremental benefit of reduced latency? <br>- Analyst complain that the data isn't up-to-date <br> &emsp;• Yesterday's data by 9am is good enough for *most* analytical use cases|
| **How Streaming Pipelines Are Different From Batch Pipelines**  | - *Streaming pipelines run 24/7*! Batch pipelines run for a small percentage of the day <br>- Streaming pipelines are much more software engineering oriented <br> &emsp;• They act more like servers than DAGs<br>- Streaming pipelines need to be treated as such and have more unit test and integration test coverage like servers! |
| **The Streaming->Batch Continuum**  | ![Streaming Pipeline Continuum](streaming_pipelines.png)<br>- The lower the latency, the higher the engineering complexity <br>- Real time is a myth!<br> &emsp;• You'll have seconds of latency just for the event generation -> Kafka -> Flink -> sink <br>- Pipelines can be broken into 4 categories <br> &emsp;• Daily batch<br> &emsp;• Hourly batch (sometimes called near real-time)<br> &emsp;• Microbatch (sometimes called near real-time)<br> &emsp;• Continuous processing (usually called real-time) |
| **Concept**  | - xxx <br> &emsp;• xxx |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx