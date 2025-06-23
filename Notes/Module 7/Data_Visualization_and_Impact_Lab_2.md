# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Data Visualization and Impact

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Exploring Data Visualization and Aggregation Techniques Day 2 Lab

Things you want to think about:

1. What questions do we want to describe?
2. How do we want to display data?

### Creating Calculated Fields

Should happen upstream, but you can do it in Tableau if needed.

1. Right click the dimension you want to calculate a field for
2. A dropdown will appear with a "create" option
3. Choose "calculated field"
4. In this case, Zach is looking for referrers from LinkedIn specifically
   - You can write SQL queries in the calculated field
   - For this tasks, we would write the following query:
   - ```IF CONTAINS([Referrer], 'linkedin') THEN 'LinkedIn' ELSEIF CONTAINS([Referrer], 'lnkd.in') THEN 'LinkedIn' ELSEIF ISNULL([Referrer]) THEN 'Direct' ELSEIF CONTAINS([Referrer], 'instagram') THEN 'Instagram' ELSEIF CONTAINS([Referrer], 'google') THEN 'Google' ELSEIF CONTAINS([Referrer], 't.co') THEN 'Twitter' ELSEIF CONTAINS([Referrer], 'eczachly') THEN 'On Site' ELSEIF CONTAINS([Referrer], 'zachwilson') THEN 'On Site' ELSE 'Other' END```
5. When you are satisfied with your SQL query, hit "Apply"
6. You can now use this dimension

Normalizing the data with table calculations helps in re-scaling the values to a *percentage of total*, which can flatten the impact of outliers for a cleaner view.

#### Editing Calculated Fields

You can edit your calculated fields using the following method:

1. Right click the dimension you want to modify the calculated field for
2. Click "edit"
3. Adjust the SQL query and hit "apply"

### Changing the Time Filter

1. Right click the dimension
2. In the dropdown that shows, you can choose either:
   - Year
   - Quarter
   - Month
   - Day
   - You can also break this down further into Hour, Minute, Second, or custom

### Excluding Data

Certain filters can be disabled by right clicking the dimension and choosing "exclude" in the dropdown menu.

### Adjusting Scale

- You can adjust the scale by right clicking the dimension and choosing "quick table calculation" from the dropdown menu
  - Choosing "Percent Total" will not immediately change anything
  - However, when you open the dropdown menu again, choose "compute using 'event time' and referrer mapped'"

**Note:** Area charts provide better visual differentiation between data points through filled areas, thereby enhancing the clarity of the data source contributions over time.

### Filtering by Count

Excessive varitey complicates analysis because it makes it difficult to focus on the most impactful data, which necessitates aggregation and simplification!

1. Bring the measure of interest to the "Filters" box
2. Choose "Range of values" and enter "1000"

### Creating a Dashboard

1. Choose the icon with the box of blocks next to the icon that creates a new sheet
2. The dashboard has access to the sheets within the book
3. Drag and drop the sheets of interest
4. You can click on the graphics to bring up more options
   - "Remove from dashboard"
   - "Go to sheet"
   - "Use as filter"
     - This is enabled when the icon is filled in, or disabled when it is not
   - More
5. Filtering by the "Traffic by OS" type dynamically shows the traffic on the area chart based on the OS type!

**You can edit the axis by right clicking.** Titles and filters can also be hidden this way.

The *"use as filter"* feature in Tableau enables dynamic filtering, allowing users to interact with one chart and automatically filter data in connected charts, enhancing the interactive experience.

### Annotating

Great for exploratory or executive dashboards!

1. Right click on a point of interest in your chart
2. Choose "annotate" from the dropdown menu
3. You can annotate specific points
   - You can drag and drop the annotation windows
   - You can include the dates/times or just the annotation
4. Annotations should hang around with the filtering

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What should you keep in mind as you are formulating Tableau dashboards?
- How do you create calculated fields?
- How do you change the time filter?
- How do you exclude data?
- How do you adjust the scale of a dimension?
- How do you create a dashboard?
- How do you annotate a chart?
- What is the difference between interactive and executive dashboards?
- What is one of the challenges mentioned when dealing with a large number of referrers in data visualization?
- How can you optimize a visual representation in Tableau when you have a dataset with many outliers?
- What type of visualization was suggested to improve the clarity of a single line chart?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

When creating Tableau dashboards, you should always ask yourself what story are you trying to tell and how things are coming across. If needed, you can create calculated fields directly within Tableau, though this should happen upstream whenever possible. Certain items can be disabled from the filtered items by right clicking and choosing "exclude" in the dropdown menu.

Executive dashboards are designed to provide high-level overviews of key metrics with minimal interaction, focusing on delivering clear and concise information efficiently to decision-makers. Interactive dashboards contain filters that may change the values of the other charts on the dashboard in order to provide a more interactive story.
