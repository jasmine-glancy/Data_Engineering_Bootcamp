import os
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, StreamTableEnvironment
from pyflink.table.expressions import lit, col
from pyflink.table.window import Session


def create_aggregated_events_sink_postgres(t_env):
    table_name = 'processed_events_aggregated'
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            event_hour TIMESTAMP(3),
            host VARCHAR,
            num_hits BIGINT
        ) WITH (
            'connector' = 'jdbc',
            'url' = '{os.environ.get("POSTGRES_URL")}',
            'table-name' = '{table_name}',
            'username' = '{os.environ.get("POSTGRES_USER", "postgres")}',
            'password' = '{os.environ.get("POSTGRES_PASSWORD", "postgres")}',
            'driver' = 'org.postgresql.Driver'
        );
    """
    t_env.execute_sql(sink_ddl)
    return table_name


def create_aggregated_events_referrer_sink_postgres(t_env):
    table_name = 'processed_events_aggregated_source'
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            event_hour TIMESTAMP(3),
            host VARCHAR,
            referrer VARCHAR,
            num_hits BIGINT
        ) WITH (
            'connector' = 'jdbc',
            'url' = '{os.environ.get("POSTGRES_URL")}',
            'table-name' = '{table_name}',
            'username' = '{os.environ.get("POSTGRES_USER", "postgres")}',
            'password' = '{os.environ.get("POSTGRES_PASSWORD", "postgres")}',
            'driver' = 'org.postgresql.Driver'
        );
    """
    t_env.execute_sql(sink_ddl)
    return table_name

def create_processed_events_source_kafka(t_env):
    kafka_key = os.environ.get("KAFKA_WEB_TRAFFIC_KEY", "")
    kafka_secret = os.environ.get("KAFKA_WEB_TRAFFIC_SECRET", "")
    table_name = "process_events_kafka"
    pattern = "yyyy-MM-dd'T'HH:mm:ss.SSSX"
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            ip VARCHAR,
            event_time VARCHAR,
            referrer VARCHAR,
            host VARCHAR,
            url VARCHAR,
            geodata VARCHAR,
            window_timestamp AS TO_TIMESTAMP(event_time, '{pattern}'),
            WATERMARK FOR window_timestamp AS window_timestamp - INTERVAL '15' SECOND
        ) WITH (
             'connector' = 'kafka',
            'properties.bootstrap.servers' = '{os.environ.get('KAFKA_URL')}',
            'topic' = '{os.environ.get('KAFKA_TOPIC')}',
            'properties.group.id' = '{os.environ.get('KAFKA_GROUP')}',
            'properties.security.protocol' = 'SASL_SSL',
            'properties.sasl.mechanism' = 'PLAIN',
            'properties.sasl.jaas.config' = 'org.apache.flink.kafka.shaded.org.apache.kafka.common.security.plain.PlainLoginModule required username=\"{kafka_key}\" password=\"{kafka_secret}\";',
            'scan.startup.mode' = 'latest-offset',
            'properties.auto.offset.reset' = 'latest',
            'format' = 'json'
        );
    """
    t_env.execute_sql(sink_ddl)
    return table_name


def log_aggregation():
    # Sets up the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    
    # Enable checkpointing every 10 seconds
    env.enable_checkpointing(10 * 1000)
    env.set_parallelism(3)
    
    # Set up the table environment
    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    
    # Table environment
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)
    
    try:
        # Create the Kafka table
        source_table = create_processed_events_source_kafka(t_env)
            
        # Perform aggregations via a session
        session_window = t_env.from_path(source_table).window(
                # Define a session window with a gap of 5 minutes
                Session.with_gap(lit(5).minutes).on("window_timestamp").alias("w")
            )\
                .group_by(
                    col("ip"),
                    col("host"),
                    col("w")
                )\
                    .select(
                        # Count events for each session
                        col("ip"),
                        col("host"),
                        col("w").start.alias("session_start"),
                        col("w").start.alias("session_end"),
                        col("*").count.alias("session_event_count")
                    )
    except Exception as e:
        print(f"Can't create session window. Exception: {e}")
                    
    try:
        # Attempt to create a temporary view and average sessions
        session_result = t_env.create_temporary_view("sessionized", session_window)
        session_result.execute().print()
        
    except Exception as e:
        print(f"Cannot create a temporary view. Exception: {e}")
        
    try:
        # Average session event count per host
        avg_per_host = t_env.from_path("sessionized") \
            .where(col("host").isin(
                "zachwilson.techcreator.io",
                "zachwilson.tech",
                "lulu.techcreator.io"
            )) \
                .group_by(col("host")) \
                    .select(
                        col("host"),
                        col("session_event_count").avg.alias("avg_events_per_session")
                    )

        try:
            # Print results to terminal for debugging
            t_env.execute_sql("""
                CREATE TABLE print_sink (
                    host VARCHAR,
                    avg_events_per_session DOUBLE
                ) WITH (
                    'connector' = 'print'
                )
            """)
            avg_per_host.execute_insert("print_sink").wait()
        except Exception as e:
            print(f"Print sink failed: {e}")


    except Exception as e:
        print(f"Aggregation failed. Exception: {e}")
        
    try: 
        # Write the results to the sink tables
        aggregated_table = create_aggregated_events_sink_postgres(t_env)
        avg_per_host.execute_insert(aggregated_table).wait()
        
    except Exception as e:
        print("Writing records from Kafka to JDBC failed:", str(e))


if __name__ == "__main__":
    log_aggregation()