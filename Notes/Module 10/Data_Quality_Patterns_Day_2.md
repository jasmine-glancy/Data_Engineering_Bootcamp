# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Data Quality Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> WAP Patterns Day 2 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **WAP Pattern**  | - Write, Audit, Publish <br> &emsp;• How you ensure good quality data gets pushed to production<br>- How it works <br> &emsp;• Write data to a staging table that has the same schema as prodution <br> &emsp;• Run your quality checks/audits <br> &emsp;• If the checks pass, publish staging to production <br>- Implementing this pattern can help prevent 80-90% of data quality issues |
| **Causes of Bad Data (not all comprehensive)**  | - Logging errors <br> &emsp;• More for fact data<br> &emsp;• i.e. a software engineer changes the schema of the logs and the table schema no longer matches <br> &emsp;• Other logging bugs<br>- Snapshotting errors<br> &emsp;• More for dimensional data<br> &emsp;• A bit rare<br> &emsp;• You are missing dimensions or users due to production data quality issues<br>- Production data quality issues <br> &emsp;• Bad data exists in production<br>- Schema evolution issues<br> &emsp;• Can happen with snapshotting and logging errors<br>- Pipeline mistakes making it into production<br>- Non-idempotent pipelines and backfill errors<br>- Not thorough enough validation |
| **Validation Best Preactices**  | - Backfill a small amount of data (~1 month)<br>- Have someone else check all your assumptions<br>- Produce a validation report <br> &emsp;• Duplicates <br> &emsp;• Nulls <br> &emsp;• Violations of business rules <br> &emsp;• Time series/volume  |
| **Writing to Production is a *Contract***  | - It means you checked the data the best you could!<br>- The components of the contract: <br> &emsp;• Schema<br> &emsp;• Quality checks<br> &emsp;• How data shows up in production |
| **Two Contract Flavors**  | ![WAP flow](wap_diagram.png)<br>1. Write, Audit, Publish (WAP) <br> &emsp;• Blocking quality checks require troubleshooting<br> &emsp;• Non-blocking quality checks don't block the data, but there's something strange with the data <br><br>- **Pros** <br> &emsp;• Downstream pipelines can intuitively depend on the production table directly<br> &emsp;• No chance of production data getting written without passing the audits<br><br>- **Cons** <br> &emsp;• Partition exchange can be something that delays the pipeline by several minues. <br> &emsp;• More likely to miss SLA<br><br>![Signal Table](signal_table_diagram.png)<br>2. Signal table <br> &emsp;• The signal table tells the downstream pipeline that the data is ready to go <br> &emsp;• The downstream needs to wait for the signal table, *not* on the production table <br> &emsp;• Does not cater to ad hoc queries very well <br><br>- **Pros** <br> &emsp;• Data lands in just one spot and never has to be moved<br> &emsp;• More likely to hit SLA <br> &emsp;• Data lands sooner<br>- **Cons** <br> &emsp;• Non-intuitive for your downstream users <br> &emsp;&emsp;• What if they forget you have a signal table? <br> &emsp;• Higher likelihood of propagating DQ errors because of this non-intuitive design<br> &emsp;• Adhoc queries may return results from data that has failed audits|
| **When These Contracts Are Violated**  | - ***PROPAGATES BAD DATA*** <br>- If you have no downstream dependencies, it's not a big issue <br>&emsp;• If you have a lot, it's a *big* issue |
| **Bad Metric Definitions**  | - Bad metric definitions can cause bad data, too. <br>- The more different data points and dimensions your metric depends on, the more prone it is to error <br> &emsp;• i.e. knowing the engagement per qualified minute of Ethiopean children who use 7 year old iPhone devices on Christmas days is going to be a "noisy" metric <br> &emsp;• Can't do data quality checks on metrics that are too narrow because you get to a point where normalities don't exist anymore|

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What does WAP stand for in the context of data quality patterns?
- What issues can be caused by a logging error in data processing?
- What is a major disadvantage of using the Signal Table pattern over the WAP pattern?
- What is an effective way to prevent bad data propagation in heavily used data pipelines?
- Why is having another person validate a data pipeline important?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

In the context of data quality patterns, WAP stands for write, audit, and publish. Logging errors can lead to incorrect row counts, schema mismatches, and issues such as double form submissions when buttons are not properly disabled.

Signal table patterns can lead to data quality issues being overlooked in ad hoc queries since data is written directly to production, whereas WAP ensures quality checks before publishing. Thorough data validation and quality checks ensure that only high-quality data is propagated, especially in pipelines with many downstream dependencies.

Having someone else validate the pipeline allows for a fresh perspective and can help identify mistakes that the original creator may have overlooked.
