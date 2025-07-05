# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Applying Analytical Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Exploring SQL, Scaling Projects and Aggregation Analysis Day 1 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **A Note To Start**  | - Not all pipelines are built differently <br> &emsp;• If you can identify higher-level patterns, you can figure out the best types of pipelines to implement <br>- ***Repeatable analyses are your best friend because they allow you to think at a higher level***<br> &emsp;• Instead of thinking about `GROUP BY` and `SELECT`, you can think a layer above this <br> &emsp;• Think of this as an "extension" of SQL |
| **Analytical Patterns**  | - Growth Accounting <br> &emsp;• i.e. how Facebook tracks inflows and outflows of active and inactive users<br> &emsp;• Or any other state change tracking <br> &emsp;• Closely related to cumulative table design concepts <br>- Survival Analysis Pattern <br> &emsp;• i.e. of all the users who are active today, how many are still around? <br>- State change tracking <br> &emsp;• Closely connected with SCDs <br> &emsp;• SCDs have records for every different value of a dimension <br> &emsp;• Instead of keeping all of the *values* of a dimension, state change logs every time the values *changed* |
| **Common Pattterns to Learn**  | - Aggregation-based patterns<br>- Cumulation-based patterns <br>- Window-based patterns <br>- Enrichment patterns do not take place in this realm because we already have all the columns we need |
| **Repeatable Analyses**  | - Reduce cognitive load of thinking about the SQL <br> &emsp;• Think bigger picture! <br> &emsp;• How can you apply higher-level patterns?<br>- Streamline your impact <br> &emsp;• xxx |
| **Aggregation-Based Patterns**  | - Most common patterns <br> &emsp;• `GROUP BY` used often<br> &emsp;• Counting things<br> &emsp;• Trend analysis <br> &emsp;• Root cause analysis<br> &emsp;&emsp;• Explaining the movement of metrics<br> &emsp;&emsp;• If you start seeing a shift in a metric, you can bring in other metrics to investigate<br> &emsp;• Percentile <br> &emsp;• Composition <br> &emsp;• Add charts showing the composition of something <br> &emsp;• **Gotchas**<br> &emsp;&emsp;• Think about the combinations that matter the most <br> &emsp;&emsp;• Be careful looking at many-combination, long-time fram analyses (> 90 days)<br> &emsp;&emsp;&emsp;• You don't want too many cuts in your data when you have a long timeframe because time is a dimension with high cardinality |
| **Cumulation-Based Patterns**  | Time is significantly different dimensions vs other ones <br>- `FULL OUTER JOIN` is your friend <br> &emsp;• Built on top of cumulative tables<br>- Common for the following patterns:  <br> &emsp;•  State transition tracking<br> &emsp;&emsp;• Shows the shift of state between yesterday and today <br> &emsp;• Retention (AKA J curves or survivor analysis)  |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx
