# <img src="../../notes/books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> SQL Basics

## <img src="../../notes/notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> GROUP BY, JOIN, and Common Table Expression Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Query Tool**  | - You can join learn.dataexpert.io/query to use the Query Editor <br> &emsp;• You can choose between Trino and Snowflake <br> &emsp;• Trino is used for this lab <br> - From a syntax standpoint, nested queries may perform differently than queries that are un-nested|
| **Aggregation**  | - Groups the data together based on certain things <br> &emsp;• `SUM()`, `AVG()`, and `COUNT()` are the most frequent <br> &emsp;• Other aggregation functions exist as well, such as `ARRAY_AGG()`<br> &emsp;• Things that are not in aggregate expressions have to be in a `GROUP BY()` if you use an aggregation function<br>- `DISTINCT()` removes duplicates<br> &emsp;• Remember, no data is also data, so remember to make sure you really need to remove duplicates!|
| **JOINS**  | - Joining on a unique primary key can extend your access to information for that unique key across multiple tables|
| **Creating New Column Names**  | - Use the AS keyword <br> &emsp;• i.e. `SUM(details.pts) AS total_ts` |
| **Common Table Expressions**  | - Use `WITH()` <br> &emsp;• To de-duplicate an item set <br> &emsp;&emsp;• `WITH deduped AS (SELECT DISTINCT player_name, game_id, pts FROM bootcamp.nba_game_details)`|
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |

## <img src="../../notes/question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../../notes/summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx
