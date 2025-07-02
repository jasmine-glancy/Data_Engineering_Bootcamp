# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Data Quality Patterns

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Spec-Building Document Day 1 Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Outline Document**  | - Includes the following: <br> &emsp;• Brief synopsis<br> &emsp;• Goal of the pipeline <br> &emsp;&emsp;• What questions do you want answered?<br> &emsp;• Business Metrics <br> &emsp;• Flow diagram <br> &emsp;• Schemas <br> &emsp;• Quality checks for each table|
| **Business Metric Table**  | - Metric Names <br> &emsp;• Should be inspired by the questions that need answering<br> &emsp;&emsp;• i.e. If you are looking at what percentage of traffic is converting to sign up, the metric would be called "signup_conversion_rate"<br>- Definition <br> &emsp;• The syntax for what gives you the metric<br> &emsp;&emsp;• `COUNT(signups)/COUNT(website_hits)` gives you signup_conversion_rate<br>- Is Guardrail <br> &emsp;• Signifies a problem to the business that is really bad <br> &emsp;• Guardrail measurements protect the business <br> &emsp;&emsp;• i.e. if an A/B test is very harmful to a specific metric, the guardrail metric would prevent the test from moving to production<br> &emsp;&emsp;• In the previous example, the signup_conversion_rate would be a guardrail metric because if the number goes down, it indicates there is a problem with the signup page|
| **Schema Breakdown**  | - Name and describe the tables you are using <br> &emsp;• Include column name<br> &emsp;• Include column type <br> &emsp;• Include column comment<br>- i.e. "user_id, BIGINT, This column is nullable for logged out events. This column indicates the user who generated this event", "dim_country, STRING, the country associated with the IP address of this request" |

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- In the context of the lab, what does a 'guardrail metric' signify?
- Why is 'sign up conversion rate' considered a guardrail metric in the lab?
- What is the purpose of including 'IP enrichment' in the data pipeline discussed in the lab?
- What type of table is 'core.fact_website_events' as discussed in the lab?
- Why are quality checks on 'event timestamp' necessary in the lab's data pipeline?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

Guardrail metrics are specifically designed to signal major issues in critical business areas, acting as protective measures. The sign up conversion rate is a guardrail metric because a drop in this rate suggests a problem with the landing page's effectiveness in converting traffic to sign-ups. In this lab, IP enrichment provides additional context by determining geographical location from IP addresses, which enhances data analysis capabilities.

The table `core.fact_website_events` in the lab includes detailed event data entries enhanced with additional context like IP and user agent information, which makes it more informative compared to raw logs. Quality checks ensure consistency by verifying all event timestamps adhere to a standard time zone (UTC), which is crucial for accurate data comparison and analysis.
