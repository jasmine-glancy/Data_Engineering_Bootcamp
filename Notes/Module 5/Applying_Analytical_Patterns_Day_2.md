# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Applying Analytical Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Recursive CTEs and Window Functions Day 2 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Funnels**  | - A massive part of analytics and data engineering <br> &emsp;• Helpful for growth, money, and engagement |
| **DE SQL vs SQL**  | - Things in data engineering SQL interviews you will almost never do on the job per EcZachly <br> &emsp;• Rewrite the query without window functions <br> &emsp;• Write a query that leverages recursive common table expressions  <br> &emsp;&emsp;• i.e. `WITH`<br> &emsp;• Using correlated subqueries in any capacity <br><br>- If you hear rank or rolling think window function! <br>- Care about the number of table scans <br> &emsp;• `COUNT(CASE WHEN)` is very powerful <br> &emsp;• Cumulative table design minimizes table scans <br> &emsp;&emsp;• You build the table incrementally <br> &emsp;• Query the minimum amount of data to solve the problem<br>- Write clean SQL code <br> &emsp;• Common table expressions are your friend <br> &emsp;• Use aliases!<br>- `EXPLAIN` shows the query under the hood<br> &emsp;• If you understand how **abstract syntax trees** (ASTs) are generated with SQL, you will practice SQL better!  |
| **Advanced SQL Techniques To Try Out**  | - `GROUPING SETS`, `GROUP BY CUBE`, `GROUP BY ROLLUP`<br> &emsp;•  A way to do multiple aggregations in one query without having to do `UNION`s <br>- Self-`JOIN`s<br>- Window functions <br> &emsp;• `LAG`, `LEAD`, `ROWS` clause <br> &emsp;• i.e. Rolling monthly average <br>- `CROSS JOIN UNNEST`, `LATERAL VIEW EXPLODE`<br> &emsp;• Do the same thing <br> &emsp;• `CROSS JOIN UNNEST` for SQL-based <br> &emsp;• `LATERAL VIEW EXPLODE` for JVM-based<br> &emsp;&emsp;• Spark, Hive |
| **GROUPING SETS**  | - [GROUPING SETS Example](#grouping-sets-example)<br>- 4 aggregatuion queries in one  <br> &emsp;• When a dimension is ignored in one of the grouping sets, it is ignored and nullified <br> &emsp;&emsp;• Make sure these are never null beforehand with `COALESCE`! |
| **Cubes**  | - [Cube Example](#cube-example) <br> &emsp;• Gives you all possible permutations<br> &emsp;• This is code example is doing 8 grains of data <br> &emsp;• You should limit your options to 3-4 dimensions because the combinations "explode"<br>- Not very scalable, but is a good way to examine possible permutations of dimensions |
| **Rollup**  | - [Rollup Example](#rollup-example) <br> &emsp;• Used for hierarchial data<br> &emsp;• Rollup gives you a number of dimensions equal to the number of dimensions you give, so it grows linearly<br>- **If you are using Big Query, you only get `ROLLUP` out of the three options! |
| **Window Functions**  | - ***IMPORTANT*** <br>- The function<br> &emsp;• `RANK`<br> &emsp;&emsp;• `RANK` skips values!<br> &emsp;• `SUM` <br> &emsp;• `AVG` <br> &emsp;• `DENSE_RANK`<br> &emsp;&emsp;• You have a tie for second place, the third place person will be fourth <br> &emsp;&emsp;• Continuous numbering <br> &emsp;• `LAG` <br> &emsp;• `LEAD`<br> &emsp;• `ROW_NUMBER` <br> &emsp;• `FIRST_VALUE`<br> &emsp;• `LAST_VALUE` <br>- The window <br> &emsp;• `PARTITION BY` <br> &emsp;• `ORDER BY` <br> &emsp;• `ROWS` <br> &emsp;&emsp;• Default value is between unbounded preceeding (left side of the window) and current row (right side)<br> &emsp;&emsp;• Looks at the data from the current row backwards in time<br> &emsp;&emsp;• If you do a `SUM` with a `PARTITION BY` and `ORDER BY` without a `ROWS` clause, you will get a cumulative sum up to that point in the rows |
| **Data Modeling vs Complex SQL**  | - If your data analysts need to do SQL gymnastics to solve their analytics problems, you could be doing a better job as a data engineer! <br> &emsp;• Your data should help them do their jobs faster |
| **Symptoms of Bad Data Modeling**  | - Slow dashboards <br> &emsp;• `GROUPING SETS` can be very useful here!  <br> &emsp;• If you are using daily or row level data in your dashboards and it isn't pre-aggregated, your dashboard will suffer <br>- Queries with a weird number of CTEs<br>- Lots of `CASE WHEN` statements in the analytics queries  |

### GROUPING SETS Example

```sql
FROM events_augmented
GROUP BY GROUPING SETS (
    (os_type, device_type, browser_type),
    (os_type, browser_type),

    -- Both of these are ignored and nullified
    (os_type),
    (browser_type)
)
```

### Cube Example

```sql
FROM events_augmented
GROUP BY CUBE(os_type, device_type, browser_type)
```

### Rollup Example

```sql

-- Group on OS type by itself, then group on OS type and device type, 
-- then group on OS type, device type, and browser type
FROM events_augmented
GROUP BY ROLLUP(os_type, device_type, browser_type)
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What is a funnel in the context of analytics and data engineering?
- Why might a data engineer be asked to rewrite a query without using window functions?
- What is the recommended function to avoid when ranking data if there is no tie?
- What is a common symptom of bad data modeling according to the lecture?
- Why is it not always beneficial to use 'CUBE' in SQL for data aggregation?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

A funnel is described as having many people at the top and fewer at the bottom, used to analyze growth and engagement. Interviewers sometimes ask to rewrite queries to assess the candidate's understanding of non-window function solutions, aligning wiht the older SQL practices. Rank often skips numbers in the cases of ties, which makes `DENSE RANK` or `ROW_NUMBER` preferable for clear sequential ranking.

Slow dashboards indicate data modeling might lack pre-aggregations, which leads to inefficiencies in data processing. Using `CUBE` can result in a combinatorial explosion of data, which creates unnecessary permutations and wastes computational resources.
