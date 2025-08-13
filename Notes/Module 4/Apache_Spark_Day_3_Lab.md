# <img src="../books.svg" alt="Stack of red books with a graduation cap on top, symbolizing education and achievement, set against a plain background" width="30" height="20" /> Unit Testing Spark Jobs

## <img src="../notes.svg" alt="Orange pencil lying diagonally on a white sheet of paper, representing note taking and documentation, with a clean and organized appearance" width="20" height="15" /> Mastering Spark and PySpark Testing Lab

| Concept                | Notes            |
|---------------------|------------------|
| **Installing/Setup**  | - [Go to the Data Engineer Handbook on GitHub](https://github.com/DataExpert-io/data-engineer-handbook/tree/main/bootcamp/materials/3-spark-fundamentals) <br> &emsp;• You can run `make up` or `docker compose up` <br> &emsp;• Clone the repo <br> &emsp;• Run `pip3 install -r requirements.txt` <br> &emsp;&emsp;• Installs chispa, pytest, pyspark, and pyspark[sql] for testing<br> &emsp;• Make sure things are running with `python3 -m pytest` <br> &emsp;&emsp;• These will run the tests within the repo|
| **Testing** | - One of the things you can do to make Spark jobs more testable is create another function outside of where you build and write that does the transformation logic <br> &emsp;• If you do this, you can test just the transformation logic in the test code <br>- conftest.py gives us Spark anywhere Spark is referenced in a file |
| **Create Functions** | - [Vertex Transformation Code](#vertex-transformation-code) <br> &emsp;• ***Every function we want to create should start with test_, otherwise pytest won't pick it up and run it as a test!*** <br>- [Vertex Generation Code](#vertex-generation-code)<br> &emsp;• We have a team schema and a team vertex schema |

### Vertex Transformation Code

```sql
def do_team_vertex_transformation(spark, dataframe):
    -- Create a view of the dataframe, then run the spark query
    dataframe.createOrReplaceTempView("teams")
    return spark.sql(query)
```

### Vertex Generation Code

```sql
from shispa.dataframe_comparer import *
from ..jobs.team_vertex_job import do_team_vertex_transformation
from collections import named tuple

TeamVertex = namedtuple("TeamVertex", "identifier type properties")
Team = namedtuple("Team", "team_id abbreviation nickname city arena yearfounded")

def test_vertex_generation(spark):
    -- Create our fake input data. Given this input, we get the expected_output
    input_date = [
        Team(1, "GSW", "Warriors", "San Francisco", "Chase Center", 1900),
        Team(1, "GSW", "Bad Warriors", "San Francisco", "Chase Center", 1900)
    ]

    input_dataframe = spark.createDataFrame(input_data)

    actual_df = do_team_vertex_transformation(spark, input_dataframe)

    expected_output = [
        TeamVertex(
            identifier=1,
            type='team',
            properties= {
                'abbreviation': 'GSW',
                'nickname': 'Warriors',
                'city': 'San Francisco',
                'arena': 'Chase Center',
                'yearfounded': 1900
            }
        )
    ]

    expected_df = spark.createDataFrame(expected_output)

    assert_df_equality(actual_df, expected_df, ignore_nullable=True)
```

## <img src="../question-and-answer.svg" alt="Two speech bubbles, one with a large letter Q and the other with a large letter A, representing a question and answer exchange in a friendly and approachable style" width="35" height="28" /> Cues

- What command is run to install the necessary requirements for testing?
- What is a key step in setting up to test PySpark jobs?
- What must be true about function names for Chipa and PyTest to recognize it as a test?
- What is the purpose of creating a separate transformation function in Spark jobs?
- What tool is used alongside PySpark to run the tests?
- In PySpark testing, what is the role of the file named 'comp test'?
- In the context of the testing framework used, what does the configuration file 'COF test' define?
- What must be true about function names for Chipa and PyTest to recognize it as a test?
- Why is it important to create a separate function for transformation logic in Spark jobs?
- What challenge can arise when transforming SQL queries for use in Spark?
- Why might a PySpark unit test fail due to schema mismatches?

---

## <img src="../summary.svg" alt="Rolled parchment scroll with visible lines, symbolizing a summary or conclusion, placed on a neutral background" width="30" height="18" /> Summary

The command `pip install -r requirements.text` is used to install all required Python packages listed in the requirements file. Cloning the data engineer handbook repository is crucial because it contains the necessary materials and setup files for the testing process. Function names must begin with "test" for Chipa and PyTest to automatically identify and execute them as test functions.

By separating the transformation logic function, you can create unit tests that focus solely on the correctness of the transformation, without being affected by the setup tasks such as Spark session creation and data output operations. Pytest is used to automate the execution of tests written for PySpark, which ensures the code logic returns as expected.

The "comp test" file is used to provide a single Spark session instance for use across different test cases. "COF test" defines the Spark session, which is then used in multiple test cases ensuring consistency and efficiency in running Spark operations. Creating a separate function for transformation logic allows for easy unit testing of that logic without needing to test the entire Spark session or data writing process.

Spark may have different syntax requirements compared to other SQL dialects, necessitating adjustments such as changing function names or data type declarations. Differences in nullable properties between expected and actual schemas can cause unit tests to fail, highlighting the importance of ensuring consistent nullable settings in data frames.
