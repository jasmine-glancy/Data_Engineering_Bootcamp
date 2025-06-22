# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Data Visualization and Impact

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Insights and Best Practices Day 2 Lecture

### Performant Dashboards Best Practices

1. ***Don't do JOINs on the fly!***
   - Exception, one side is very tiny.
   - If both sides are substansial at all, don't do this!
   - When you are in the dashboard, you should not be thinking about scalability because *you are at the final layer*. The only thing downstream is the human, so please refine things.
   - JOINs are resource-intensive, especially with large datasets, which reduces dashboard efficiency
2. Pre-aggregate the data!
   - GROUPING SETS are your friend
     - You can pick the dimensional gain that you want to build fast dashboards
   - **The trade-off:** when you pre-aggregate, you lose a certain layer of detail, but it loads instantly
3. Use a low-latency storage solution like Druid

If you do all three of these things, your dashboards will always load instantly regardless of the scalability or complexity! **Think about the end user.**

### Building Dashboards That Make Sense

Ask yourself: who is your customer?

- Executives
  - No interaction
  - Need quick insights without the distraction of additional data exploration, thus a direct presentation of key metrics is preferred.
- Analysts
  - Like more charts, more density, more exploration capabilities
  - May not use pre-aggregates for them so they can filter more finely

### Types of Questions That Can Be Asked

1. Top line questions
   - How many users do we have?
   - How much money do we make?
   - How much time are people spending on the app?
   - May have a filter component (i.e. how many users in India?)
2. Trend questions
    - How many users did we have this year versus last year?
    - Have a time component
3. Composition questions
   - What percentage of our users use android over iPhone?

### Which Numbers Matter?

- Total aggregates (`COUNT *`)
- Time-based aggregates
- Time & Entity-based aggregates
- Derivative metrics (week-over-week, month-over-month, year-over-year)
  - Very powerful!
- Dimensional mix (eg. % US vs % India vs % Android vs % iPhone)
  - Sometimes the dimensional mix can change, but the total aggregate stays the same
  - ***Mix shift***: if you have a metric tied to a dimension, sometimes the dimension-specific metric can drop, but it doesn't have any impact on the business because the value just changed.
    - The user is still there, they just don't have the original dimension they had
- Retention / Survivorship (% left after N number of days)

#### Total Aggregates

- Get reported to Wall Street
- Can easily be used in marketing material
- Are the "top of the line" and represent how good or bad the business is doing overall

#### Time-Based Aggregates

- Get reported to Wall Street
- Catch trends earlier than totals (a bad quarter is a potential signal of a bad year)
- These charts identify trends and growth

#### Time & Entity-Based Aggregates

i.e. Daily user-level metrics

- Easily plug into AB testing framework
- Used by data scientists to look cut aggregated fact data in a way that is performant
- Often times included in daily master data
- Not often reported to Wall street

#### Derivative Metrics

- More sensitive to change than normal aggregates are
- % increase is a better indicator than an absolute number
- Illustrate where the growth is headed

#### Dimensional Mix

- Identifies impact opportunities
- Spot trends in populations, not just over time
- Good for root cause analysis

#### Retention / Survivorship

- Also called **J-curves**
- The percentage left after N number of days
- Great at predicting lifetime value
- Understanding stickiness of the app you're building

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What are the best practices for performant dashboards?
- How do you build dashboards that make sense?
- What kinds of questions can be asked about your dashboards and visualizations?
- What is mix shift?
- Why is it important not to perform joins on the fly when building dashboards?
- What is a major consideration when pre-aggregating data for dashboards?
- What is a key distinction between derivative metrics and total aggregates?
- Why should dashboards build on data from low-latency stores?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

In terms of dashboard performance, the most important thing to remember is to not do JOINs on the fly. When possible, data should be pre-aggregated. While this makes things faster, it does cause a certain level of loss of detail, so if you are creating dashboards for data scientists it may be a good idea to skip this step.

When building dashboards, you should ask yourself who your end user will be. You may be asked top line, trend, or composition questions about the dashboards and visuals you will provide. Derivitive metrics are more sensitive to change and can illustrate where growth is headed.
