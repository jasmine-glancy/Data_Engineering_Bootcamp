# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> PyIceberg

Have you ever read Spark code before? If not, it may look alien! This guide is a compilation of notes taken while reading the PyIceberg Guides that were helpfully written by the team at [DataExpert.io](dataexpert.io). Please check them out!

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Getting Started

### Imports

```python
from pyiceberg import __version__

__version__
```

### Importing Data

This notebook uses the New York City Taxi and Limousine Commision Trip Record Data that's available on the AWS Open Data Registry. This contains data of trips taken by taxis and for-hire vehicles in New York City.

```python
# Load the Parquet file using PyArrow
import pyarrow.parquet as pq

# Read the data into a new Iceberg table called tbi_taxis
tbi_taxis = pq.read_table("/home/iceberg/data/yellow_tripdata_2021-04.parquet")
tbi_taxis
```

### CRUD Operations

#### Creating Tables

*Create the Namespace*

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

*Create the Taxis table from the schema that's derived from the Arrow schema*



## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- xxx

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

xxx