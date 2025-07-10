# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Applying Analytical Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Aggregations and Cardinality Reduction Day 2 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Goal**  | - Count the number of signup visits that have happened by browser type, OS type, device type, referrer |
| **Create a CTE**  | - [Create the First CTE](#create-the-first-cte) <br> &emsp;• Reduces cardinality |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |

### Create the First CTE

```sql
WITH combined AS (
    SELECT d.*, we.*

    -- Reduce the cardinality of referrer
    CASE 
        WHEN referrer LIKE '%zachwilson%' THEN 'On Site'
        WHEN referrer LIKE '%eczachly%' THEN 'On Site'
        WHEN referrer LIKE '%dataengineer.io%' THEN 'On Site'
        WHEN referrer LIKE '%t.co%' THEN 'Twitter'
        WHEN referrer LIKE '%linkedin%' THEN 'LinkedIn'
        WHEN referrer LIKE '%instagram%' THEN 'Instagram'
        WHEN referrer IS NULL THEN 'Direct'
        ELSE 'Other'
        END AS referrer_mapped
FROM bootcamp.web_events we JOIN bootcamp.devices d
ON we.device_id = d.device_id
WHERE url = '/signup'
)

-- Outputs the referrer source with the number of users 
SELECT referrer_mapped, COUNT(1) FROM combined
GROUP BY 1
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx