# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Data Visualization and Impact

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Hands-On with the CSV files Day 1 Lab

In Tableau Desktop:

1. Import text file (either events or devices)
2. Drag devices.csv onto the workspace

### Tableau Features

Clicking Sheet 1 (or any other numbered sheet) will allow you to see more information about the data columns in the file.

- The blue icons represent dimensions
- The green icons represent measures
  - In this lab, counts are the only measures discussed in this session

When you want to aggregate data from events and devices, join devices.csv and events.csv using device ID.

#### Creating Filters

1. Right click "Host"
2. Create -> Set
3. Create Host Set
4. Rename to "Top 7 Hosts"
5. Click "Top"
6. Click "By Field"
7. Enter "Top 7 by events.csv count"
8. Click "OK"
9. Drag the "Top 7 Hosts" Set into the Filters box

That's great, but there isn't a time dimension visible. *You can also drag the Event Time into the Filters box!*

But what if you want to look at the proportion of the traffic as opposed to the count?

### Quick Table Calculations

**Right clicking** on the measure pill will bring up a drop down menu. Choosing *quick table calculation* gives more options:

- Running total
- Difference
- Oercent difference
- Percent of total
- Rank
- and more!

Once you choose a value to calculate, right clicking on the measure pill again will give you an option to *compute* using either:

- Table (across)
- Table (down)
- Table
- Cell
- Event Time
- Host

Initially, the percent of total was not displaying correctly because it was mnot properly set to compute using both event time and the host, so it needed adjusting.

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What action should be taken in Tableau when you want to aggregate data from events and devices?
- What are the measures in the data set discussed during the lab session?
- How do you create a filter for the top 7 hosts in Tableau?
- In the context of Tableau visualizations, what combination was incorrect and needed adjusting for accurate proportions?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

Tableau Desktop has a slightly different import pane in terms of visualization compared to the web application. Once data is imported, going to the sheet's tab and viewing the table information will include icons that are either blue or green. Blue icons represent dimensions, while green icons represent measures (counts). Tables can have filters or calculations that allow you to slice down the data to display things in various ways!
