# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> KPI and Experimentation

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Decoding Business Success: Metrics, Growth Strategies and Collaborative Approaches Day 1 Lecture


| Concept                | Notes            |
|---------------------|------------------|
| **Why should a data engineer develop good ***Key Performance Indicators (KPIs)***?**  | - They impact business decision making <br>  &emsp;• Are impacted by experiments <br>- The culture set by the company's founder can influence how vital metrics are to the business |
| **Types of Metrics**  | - **Aggregates/counts** <br>  &emsp;• The "Swiss army knife" and the most common type data engineers should work with <br>  &emsp;• You will want to bring in dimensions<br> - **Ratios** <br> &emsp;• Data scientists supply numerators and denominators <br> &emsp;• Examples:<br> &emsp;&emsp;• Click through rate<br> &emsp;&emsp;• Conversion rate<br> &emsp;&emsp;• Purchase rate<br> &emsp;&emsp;• Cost to aquire a customer <br>  &emsp;• Indicate quality <br>&emsp;• Data engineers should supply sample aggregates and leave ratio metrics to data scientists, as complex ratio metrics often involve statistical expertise beyond data engineering <br> - **Percentiles** (such as p10, p50, p90 values) <br>&emsp;• Useful for measuring the experience at the extremes<br>&emsp;• Examples:<br> &emsp;&emsp;• P99 latency <br> &emsp;&emsp;&emsp;• "When our website loads for the slowest 1%, how fast is the website?" or "How fast is our worst experience?"<br> &emsp;&emsp;• P10 engagement of active users<br>- If you define a metric, ***you should be able to answer any question about that metric!***|
| **Gaming metrics**  | - Experiments can move metrics up short-term but down long-term! <br>- i.e. Sending more notifications may get more users in the short term<br>-  Increased user retention at extreme cost <br>- Experiments <br> &emsp;• Fiddle with the numerator or the denominator<br> &emsp;• Have clear hypotheses so you have some guidance when creating your experiments!<br> &emsp;• If you do not carefully consider your metrics, experiments can be manipulated or suffer from novelty effects, leading to misleading conclusions<br> &emsp;• Novelty effects of experiments <br>&emsp;&emsp;• If you introduce new things, users will generally be excited by a difference |
| **Inner workings of experimentation**  | - Make a hypothesis! <br>- Group assignment (think test vs control) <br>- Collect data <br>- Look at the differences between the groups <br>- Hypothesis testing  <br>- The Null Hypothesis (also called H naught) <br> &emsp;• Says there is no difference between the test and control (there will be no significant change) <br>- The alternative hypothesis <br> &emsp;• There is a significant difference from the changes <br>-  ***You never prove the alternative hypothesis! You fail to reject the null hypothesis!*** |
| **Group testing**  | - Uses a fraction of the userbase <br>&emsp;• Who is eligible for group testing? <br>&emsp;• Logged in experiments can be more impactful than logged out as it provides more data <br>&emsp;• **If you use logged out experiments, use hashed IP address or use a stable device ID to ensure you are counting for individuals** <br>&emsp;• Track your events! <br>- What percentage of users do we want to experiment on? <br>- Are the users in a long-term holdout? <br>&emsp;• This is the first thing you want to test <br>&emsp;• Long-running experiments that measure the effectiveness and health of various parts of the application|
| **Collecting data**  | - You collect data until you get a statistically significant result <br>&emsp;• The longer you collect data, the more likely you will be to get a statistically significant result <br>&emsp;• The smaller the effect, the longer you will have to wait <br>&emsp;&emsp;• *Some effects may be so small, you'll never get a statistically significant result.*<br>- Use stable identifiers! <br>&emsp;• This can be done in Statsig <br>- Do not **underpower** your experiments <br>&emsp;• The more test cells you have, the more data you will need to collect! <br>&emsp;• It's unlikely you will have the same data collection as Google <br>- ***Set up logging so you can collect all the events and dimensions you want to measure differences*** |
| **P values**  | - ***P values*** pick out change and are a method used to determine if a coincidence is actually a coincidence or not <br> &emsp;• P < 0.05 is the industry standard, but you may want higher or lower depending on your situation. <br>&emsp;&emsp;• If the P value is less than 0.05, it means 95% is not due to chance and is due to some other factor <br>&emsp;&emsp;• The lower the P value, the higher the chance is that it is not random<br>- Just because something is statistically significant doesn't mean it is valueable!|
| **Statistical significance "Gotchas"**  | - When looking at count data, extreme outliers can skew the distribution the wrong way  <br>&emsp;• ***Winsorization*** helps with this <br>&emsp;&emsp;• If the outliers are so extreme, you can clip them to a less extreme value<br>&emsp;• You can also look at user counts instead of event counts depending on what you are trying to measure |
| **Adding your own metrics outside of Statsig**  | - You can do so via batch ETLs <br>- This is a common pattern in big tech for data engineers to own these |

## <img src="../question-and-answer.svg" alt="TTwo speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- How do you plug metrics into experimentation frameworks?
- What are the types of metrics?
- When would you want to use aggregates, counts, ratios, and/or percentiles?
- How do experiments work?
- How do you look for statistical significance?
- What is the P value?
- What is winsorization?
- What is the primary reason a data engineer should develop good KPIs?
- Why should data engineers leave complex ratio metrics to data scientists?
- What is a potential risk when running experiments without careful metric consideration?
- Why do some companies place less importance on metrics according to the lecture?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

It is imperative to develop good KPIs because it directly impacts business decisions. There are several metrics that can be measured with experiments, and you want to carefully consider which ones you use. Log data during your experiments so you can analyze the P-value to check for statistical significance. When outliers are extreme, you can use winsorization to clip outliers to a less extreme value to avoid data skewing.
