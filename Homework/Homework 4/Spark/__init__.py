from pyspark.sql import SparkSession
from pyspark.sql.functions import expr, col

# Builds the app if it doesn't exist
spark = SparkSession.builder.appName("Jupyter").getOrCreate()

# Read the events from the CSV
df = spark.read.option("header", "true") \
        .csv("/home/iceberg/data/event_data.csv") \
        .withColumn("event_date", expr("DATE_TRUNC('day', event_time)"))
        
# Use show over collect() to reduce the risk of OOM errors
df.show()