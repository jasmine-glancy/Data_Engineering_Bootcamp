# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> PyIceberg

Have you ever read Spark code before? If not, it may look alien! This guide is a compilation of notes taken while reading the PyIceberg Guides that were helpfully written by the team at [DataExpert.io](dataexpert.io). Please check them out!

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Getting Started

This guide demonstrates writing to Iceberg tables using PyIceberg.

### Connecting to the Catalog

```python
from pyiceberg.catalog import load_catalog

# Connects to the place where the tables are being tracked
catalog = load_catalog("default")
```

### Imports

```python
from pyiceberg import __version__

__version__
```

### Importing Data

This notebook uses the New York City Taxi and Limousine Commision Trip Record Data that's available on the AWS Open Data Registry. This contains data of trips taken by taxis and for-hire vehicles in New York City.

#### Importing Using Arrow

```python
# Load the Parquet file using PyArrow
import pyarrow.parquet as pq

# Read the data into a new Iceberg table called tbi_taxis
tbi_taxis = pq.read_table("/home/iceberg/data/yellow_tripdata_2021-04.parquet")
tbi_taxis
```

### Creating, Updating, and Writing

#### Creating Tables

Create the Namespace

```python
from pyiceberg.catalog import load_catalog
from pyiceberg.exceptions import NamespaceAlreadyExistsError

# Create the namespace
cat = load_catalog("default")

try:
    cat.create_namespace("default")
except NamespaceAlreadyExistsError
    # Continue on if the namespace already exists
    pass
```

Create the Taxis table from the schema that's derived from the Arrow schema

```python
from pyiceberg.exceptions import NoSuchTableError

# If the default.taxis table already exists, drop it 
try:
    cat.drop_table("default.taxis")
except NoSuchTableError:
    pass

# Create the new taxis table in Iceberg with the Arrow schema
tbl = cat.create_table(
    "default.taxis",
    schema=tbi_taxis.schema
)

tbl
```

#### Updating/Writing Data

***Write*** Data into the Table

```python
tbl.overwrite(tbl_taxis)
```

***Append*** More Data

```python
tbl.append(pq.read_table("home/iceberg/data/yellow_tipdata_2021-05.parquet"))

# Returns metadata about the lastest state of the table
# i.e. snapshot ID, timestamp, summary of changes, cast as string
str(tbl.current_snapshot())
```

Load Data into a PyArrow Dataframe

```python
# Fetch the table using the REST catalog that comes with the setup
tbl = cat.load_table("default.taxis")

# Return rows that match a pickup time greater than or equal to the datetime specified
# Similar to SELECT ... WHERE...
sc = tbl.scan(row_filter="tpep_pickup_datetime >= '2021-05-01T00:00:00.000000'")

# Converts the scan result to a Pandas DataFrame
df = sc.to_arrow().to_pandas()

# Return the number of rows in the data frame
len(df)

# Prints a summary of the DataFrame
# including column names, data types, and non-null counts
df.info()

# Display the dataframe
df
```

### Creating Histograms

```python
# Creates and displays a histogram plot of the values in fair_amount
df.hist(column="fare_amount")

import numpy as np
from scipy import stats

stats.zscore(df["fare_amount"])

# Remove everything larger than 3 stddev
df - df[(np.abs(stats.zscore(df["fare_amount"])) < 3)]

# Remove everything below zero
df = df[df["fare_amount"] > 0]

# Create and display a histogram of fare_amount
df.hist(column="fare_amount")
```

### Verifying Information via DuckDB

Use DuckDB to Query the PyArrow Dataframe directly.

```python
# Loads the ipothon-sql extension so you can run queries in the Jupyter notebook
%load_ext sql

# Configures the SQL magic so the query results 
# are automatically returned as Pandas DataFrames
%config SqlMagic.autopandas = True

# Disables feedback like "returned x rows" after running queries
%config SqlMagic.feedback = False

# Disables displaying the connection string after connecting
%config SqlMagic.displaycon = False

# Connects the SQL magic to an in-memory DuckDB database, and all
# Subsequent %sql or %%sql queries will run against the DuckDB instance
%sql duckdb:///:memory:
```

#### Verify the Histogram Information From Earlier

```python
%sql SELECT * FROM df LIMIT 20

# Saves the SQL query in a named variable called tip_amount
%%sql --save tip_amount --no-execute

SELECT tip_amount
FROM df

# Plots the tip amount on a histogram with 22 bins
# --with tip_amount means the histogram will be plotted with the results of the saved query, not the raw query
%sqlplot histogram --table df --column tip_amount --bins 22 --with tip_amount

%%sql --save tip_amount_filtered --no-execute

WITH tip_amount_stddev AS (
    # Calculates the population of standard deviation of tip_amount
    SELECT STDDEV_POP(tip_amount) AS tip_amount_stddev
    FROM df
)

SELECT tip_amount

# CROSS Joins the single-row result from the CTE to every row in the df,
# so you can use the tip_amount_stddev in your WHERE clause
FROM df, tip_amount_stddev
WHERE tip_amount > 0
    # Removes extreme outliers
    AND tip_amount < tip_amount_stddev * 3

# Plots the filtered tip amount on a histogram with 50 bins
%sqlplot histogram --table tip_amount_filtered --column tip_amount --bins 50 --with tip_amount_filtered
```

### Feature Generation

If we wanted to train a model to determine which features contribute to the tip amount, tip_per_mile is a good target to train the model on. **We need to evolve the schema before we try to append the data.**

```python
import pyarrow.compute AS pc

# Scans the Iceberg table & converts results to a PyArrow Table
df = table.scan().to_arrow()

# Add a new column "tip_per_mile" by dividing "tip_amount" and "trip_distance"
df = df.append_column("tip_per_mile", pc.divide(df["tip_amount"], df["trip_distance"]))

# Attempt to overwrite the Iceberg table with the new DataFrame
try:
    table.overwrite(df)
except ValueError AS e:
    # If the schema of the DataFrame doesn't match, raise ValueError
    print(f"Error: {e}")

# Print the updated schema to verify the new column is included
print(str(table.schema()))

# Overwrite the table when the schema matches
table.overwrite(df)
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx