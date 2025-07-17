# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Fact Data Modeling

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Core Concepts, Deduplication Day 1 Lecture

| Concept                | Notes            |
|---------------------|------------------|
| **Fact Data**  | - Can bery large compared to dimensional data <br> &emsp;• Event logging, high volume <br>- A fact can be thought of as **something that happened or occurred**<br> &emsp;• A user logs in to an app <br> &emsp;• A transaction is made <br> &emsp;• You run a mile with your fitbit <br><br>- Are not slowly changing, which makes them easier to model than dimensions in some respects<br>- Aggregations can be done in layers |
| **What Makes Fact Modeling Hard?**  | - Fact data is usually 10-100x the volume of dimension data <br> &emsp;• You can roughly predict how the fact data will balloon by examining how many actions are taken per dimension <br>- Fact data can need a lot of context for effective analysis <br>- Duplicates in facts are way more common than in dimensional data |
| **Fact Modeling**  | - Normalization vs Denormalization <br> &emsp;• Normalized facts don't have any dimensional attributes, just IDs to join to get that information<br> &emsp;&emsp;• The smaller the scale, the better normalization will be for your purposes <br> &emsp;• Denormalized facts bring in some dimensional attributes for quicker analysis at the cost of more storage <br>- Both have a place in the world! <br><br>- Think of facts as a who, what, when, where, or a how <br> &emsp;• "Who" fields are usually pushed out as IDs (this user clicked this button)<br> &emsp;&emsp;• In this instance, we only hold the user_id, not the entire user object <br> &emsp;• "Where" fields <br> &emsp;&emsp;• Most likely modeled out like Who with "IDs" to join, but more likely to bring in dimensions, especially if they're high cardinality like "device_id" <br> &emsp;• "How" fields <br> &emsp;&emsp;• How fields are very similar to "Where" fields. <br> &emsp;&emsp;&emsp;• i.e. He used an iPhone to make this click <br> &emsp;• "What" fields are fundamentally part of the nature of the fact <br> &emsp;&emsp;• In the notification world - "generated", "sent", "clicked", "delivered" <br> &emsp;• "When" fields are fundamentally part of the nature of the act <br> &emsp;&emsp;• Mostly an "event_timestamp" field or "event_date" |
| **Raw Logs vs Fact Data**  | - Fact data and raw logs are not the same thing <br> &emsp;• Raw logs <br> &emsp;&emsp;• Ugly schemas designed for online systems <br> &emsp;&emsp;• Potentially contains duplicates and other quality errors <br> &emsp;&emsp;•  Usually shorter retention<br> &emsp;• Fact data <br> &emsp;&emsp;• Nice column names <br> &emsp;&emsp;• Quality guarantees like uniqueness, not null, etc <br> &emsp;&emsp;• Longer retention <br> &emsp;&emsp;• Should be as trustworthy as the raw logs|
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |
| **Concept**  | - xxx <br> &emsp;• xxx |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx
