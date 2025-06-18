## <img src="./books.svg" alt="A stack of books with a graduation cap" title="Title" width="30" height="20" /> KPI and Experimentation

### <img src="./notes.svg" alt="A pencil with a sheet of paper" title="Title" width="20" height="15" />Decoding Business Success: Metrics, Growth Strategies and Collaborative Approaches Day 1 Lecture

- Why should a data engineer develop good ***Key Performance Indicators (KPIs)***?
  - They impact business decision making
    - Are impacted by experiments
  - The culture set by the company's founder can influence how vital metrics are to the business
- Types of metrics
  - Aggregates/counts
    - The "Swiss army knife" and the most common type data engineers should work with
    - You will want to bring in dimensions
  - Ratios
    - Data scientists supply numerators and denominators
    - Examples:
      - Click through rate
      - Conversion rate
      - Purchase rate
      - Cost to aquire a customer
    - Indicate quality
    - Data engineers should supply sample aggregates and leave ratio metrics to data scientists, as complex ratio metrics often involve statistical expertise beyond data engineering
  - Percentiles (such as p10, p50, p90 values)
    - Useful for measuring the experience at the extremes
    - Examples:
      - P99 latency
        - "When our website loads for the slowest 1%, how fast is the website?" or "How fast is our worst experience?"
      - P10 engagement of active users
- If you define a metric, you should be able to answer any question about that metric!
- Gaming metrics
  - Experiments can move metrics up short-term but down long-term!
  - i.e. Sending more notifications may get more users in the short term
  - Increased user retention at extreme cost
  - Experiments
    - Fiddle with the numerator or the denominator
    - Have clear hypotheses so you have some guidance when creating your experiments!
    - If you do not carefully consider your metrics, experiments can be manipulated or suffer from novelty effects, leading to misleading conclusions
    - Novelty effects of experiments
      - If you introduce new things, users will generally be excited by a difference
- Inner workings of experimentation
  - Make a hypothesis!
  - Group assignment (think test vs control)
  - Collect data
  - Look at the differences between the groups
- Hypothesis testing
  - The Null Hypothesis (also called H naught)
    - Says there is no difference between the test and control (there will be no significant change )
  - The alternative hypothesis
    - There is a significant difference from the changes
  - ***You never prove the alternative hypothesis! You fail to reject the null hypothesis!***
- Group testing
  - Uses a fraction of the userbase
    - Who is eligible for group testing?
    - Logged in experiments can be more impactful than logged out as it provides more data
    - **If you use logged out experiments, use hashed IP address or use a stable device ID to ensure you are counting for individuals**
    - Track your events!
  - What percentage of users do we want to experiment on?
  - Are the users in a long-term holdout?
    - This is the first thing you want to test
    - Long-running experiments that measure the effectiveness and health of various parts of the application
- Collecting data
  - You collect data until you get a statistically significant result
    - The longer you collect data, the more likely you will be to get a statistically significant result
    - The smaller the effect, the longer you will have to wait
      - *Some effects may be so small, you'll never get a statistically significant result.*
  - Use stable identifiers!
    - This can be done in Statsig
  - Do not **underpower** your experiments
    - The more test cells you have, the more data you will need to collect!
    - It's unlikely you will have the same data collection as Google
  - ***Set up logging so you can collect all the events and dimensions you want to measure differences***
- ***P values*** pick out change and are a method used to determine if a coincidence is actually a coincidence or not
  - P < 0.05 is the industry standard, but you may want higher or lower depending on your situation.
    - If the P value is less than 0.05, it means 95% is not due to chance and is due to some other factor
    - The lower the P value, the higher the chance is that it is not random
- Just because something is statistically significant doesn't mean it is valueable!
- Statistical significance "Gotchas"
  - When looking at count data, extreme outliers can skew the distribution the wrong way
    - ***Winsorization*** helps with this
      - If the outliers are so extreme, you can clip them to a less extreme value
    - You can also look at user counts instead of event counts depending on what you are trying to measure
- Adding your own metrics outside of Statsig
  - You can do so via batch ETLs
  - This is a common pattern in big tech for data engineers to own these

### <img src="./question-and-answer.svg" alt="Two speech bubbles. One has the letter Q and one has the letter A" title="Title" width="35" height="28" /> Cues

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

### <img src="./summary.svg" alt="A scroll" title="Title" width="30" height="18" /> Summary

It is imperative to develop good KPIs because it directly impacts business decisions. There are several metrics that can be measured with experiments, and you want to carefully consider which ones you use. Log data during your experiments so you can analyze the P-value to check for statistical significance. When outliers are extreme, you can use winsorization to clip outliers to a less extreme value to avoid data skewing.