# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Dimensional Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Graph Data Modeling Day 3 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Graph Data Modeling**  | - More *relationship* focused and less entity focused <br>  &emsp;• Looks at how things are connected <br>  &emsp;• Flexible schema |
| **Flexible Data Types**  | - `MAP` is an example of a flexible data type <br>  &emsp;• `STRUCT` is not flexible<br>  &emsp;• `ARRAY` is semi-flexible |
| **Additive Dimensions**  | - Are not double-counted<br>- If you take the subtotals of everything, and add them together to get a grand total<br>  &emsp;• Example: Age is additive <br>  &emsp;&emsp;• The population is equal to 20 year olds + 30 year olds + 40 year olds...<br>  &emsp;• Application interface is NOT additive<br>  &emsp;&emsp;• The number of active users!= # of users on web + # of users on Android +# of users on iphone<br>  &emsp;• Counting drivers by cars is NOT additive<br>  &emsp;&emsp;• The number of Honda drivers != # of Civic drivers + # of Corolla driver + # of accord drivers <br>- Can an entity have 2 dimensional values at the same time over some time frame?<br>- **A dimension is additive over a specific window of time, if and only if, the grain of data over that window can only ever be one value at a time!** <br><br> Always think about how your dimensions interact with time!|
| **How Does Additivity Help?**  | - You don't need to use `COUNT(DISTINCT)` on preaggregated dimensions<br>- Remember non-additive dimensions are usually only non-additive with respect to `COUNT` aggregagtions, but not `SUM` aggregations! <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |
| **Concept**  | - xxx <br>  &emsp;• xxx |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx