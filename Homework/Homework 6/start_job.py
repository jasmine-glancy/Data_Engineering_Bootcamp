from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table.udf import ScalarFunction, udf
import os
import json
import requests
from pyflink.table import EnvironmentSettings, DataTypes, TableEnvironment, StreamTableEnvironment


def create_processed_events_sink_kafka(t_env):
    table_name = "raw_events_kafka"
    
    # Add the keys if found, otherwise return an empty string
    kafka_key = os.environ.get("KAFKA_WEB_TRAFFIC_KEY", "")
    kafka_secret = os.environ.get("KAFKA_WEB_TRAFFIC_SECRET", "")
    sasl_config = f"org.apache.kafka.common.security.plain.PlainLoginModule required username='{kafka_key}' password='{kafka_secret}'"
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            ip VARCHAR,
            event_timestamp TIMESTAMP(3),
            referrer VARCHAR,
            host VARCHAR,
            url VARCHAR,
            geodata VARCHAR
        ) WITH (
            'connector' = 'kafka',
            'properties.bootstrap.servers' = '{os.environ.get('KAFKA_URL')}',
            'topic' = '{os.environ.get('KAFKA_GROUP').split('.')[0] + '.' + table_name}',
            'properties.ssl.endpoint.identification.algorithm' = '',
            'properties.group.id' = '{os.environ.get('KAFKA_GROUP')}',
            'properties.security.protocol' = 'SASL_SSL',
            'properties.sasl.jaas.config' = '{sasl_config}',
            'format' = 'json'
        )
    """
    print(sink_ddl)
    t_env.execute_sql(sink_ddl)
    return table_name


def create_processed_events_sink_postgres(t_env):
    table_name = "processed_events"
    
    try: 
        sink_ddl = f"""
            CREATE TABLE {table_name} (
                ip VARCHAR,
                event_timestamp TIMESTAMP(3),
                referrer VARCHAR,
                host VARCHAR,
                url VARCHAR,
                geodata VARCHAR
            ) WITH (
                'connector' = 'jdbc',
                'url' = '{os.environ.get("POSTGRES_URL")}',
                'table-name' = '{table_name}',
                'username' = '{os.environ.get("POSTGRES_USER", "postgres")}',
                'password' = '{os.environ.get("POSTGRES_PASSWORD", "postgres")}',
                'driver' = 'org.postgresql.Driver'
            );
        """
        
        # Debugging
        print(sink_ddl)
        
        t_env.execute_sql(sink_ddl)
            
    except Exception as e:
        print(f"Unable to create processed events table. Exception: {e}")
        
    return table_name

def create_user_sessions_sink_postgres(t_env):
    table_name = "user_sessions"
    
    try:
        sink_ddl = f"""
            CREATE TABLE {table_name} (
                ip VARCHAR,
                host VARCHAR,
                session_start TIMESTAMP(3),
                session_end TIMESTAMP(3),
                event_count INTEGER
            ) WITH (
                'connector' = 'jdbc',
                'url' = '{os.environ.get("POSTGRES_URL")}',
                'table-name' = '{table_name}',
                'username' = '{os.environ.get("POSTGRES_USER", "postgres")}',
                'password' = '{os.environ.get("POSTGRES_PASSWORD", "postgres")}',
                'driver' = 'org.postgresql.Driver'
            );
        """
        
        # Debugging
        print(sink_ddl)
        t_env.execute_sql(sink_ddl)
            
    except Exception as e:
        print(f"Unable to create user sessions table. Exception: {e}")
        
    return table_name

class GetLocation(ScalarFunction):
    def eval(self, ip_address):
        url = "https://api.ip2location.io"
        response = requests.get(url=url, params={
            'ip': ip_address,
            'key': os.environ.get("IP_ADDRESS")
        })
        
        if response.status_code != 200:
            # Return an empty dictionary if the request fails
            return json.dumps({})
        
        data = json.loads(response.text)
        
        # Extract the location data
        country = data.get("country_code", "")
        state = data.get("region_name", "")
        city = data.get("city_name", "")
        
        return json.dumps({"country": country, "state": state, "city": city})
    
get_location = udf(GetLocation(), result_type=DataTypes.STRING())
        
def create_events_source_kafka(t_env):
    kafka_key = os.environ.get("KAFKA_WEB_TRAFFIC_KEY", "")
    kafka_secret = os.environ.get("KAFKA_WEB_TRAFFIC_SECRET", "")
    table_name = "events"
    pattern = "yyyy-MM-dd''T''HH:mm:ss.SSSX"    
    try: 
        # Attempt to create the events table
        source_ddl = f"""
            CREATE TABLE {table_name} (
                url VARCHAR,
                referrer VARCHAR,
                user_agent VARCHAR,
                host VARCHAR,
                ip VARCHAR,
                headers VARCHAR,
                event_time VARCHAR,
                event_timestamp AS TO_TIMESTAMP(event_time, '{pattern}'),
                WATERMARK FOR event_timestamp AS event_timestamp - INTERVAL '15' SECOND
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
        print(source_ddl)
        t_env.execute_sql(source_ddl)
        
    except Exception as e:
        print(f"Unable to create events table. Exception: {e}")
        
    return table_name


def log_processing():
    print("Starting the job!")
    
    # Set up the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    print("Got the streaming environment!")
    env.enable_checkpointing(10 * 1000)
    env.set_parallelism(1)
    
    # Set up the table environment
    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)
    t_env.create_temporary_function("get_location", get_location)
    
    # Create source and sink tables
    source_table = create_events_source_kafka(t_env)
    processed_sink = create_processed_events_sink_postgres(t_env)
    sessions_sink = create_user_sessions_sink_postgres(t_env)
    
    try:
        # Insert the enriched events into processed_events
        source_table = create_events_source_kafka(t_env)
        print("Inserting enriched events into processed_events...")
        t_env.execute_sql(
            f"""
                INSERT INTO {processed_sink}
                SELECT
                    ip,
                    event_timestamp,
                    referrer,
                    host,
                    url,
                    get_location(ip) AS geodata
                FROM {source_table};
            """
        ).wait()
    except Exception as e:
        print(f"Unable to write from Kafka to JDBC: {e}")

    try:
        # Try to create a user session
        source_table = create_events_source_kafka(t_env)
        print("Inserting sessionized results into user_sessions...")
        
        t_env.execute_sql(
            f"""
                INSERT INTO {sessions_sink}
                SELECT
                    ip,
                    host,
                    SESSION_START(event_timestamp, INTERVAL '5' MINUTE) AS session_start,
                    SESSION_END(event_timestamp, INTERVAL '5' MINUTE) AS session_end,
                    COUNT(*) AS event_count
                FROM {source_table}
                GROUP BY
                    ip,
                    host,
                    SESSION(event_timestamp, INTERVAL '5' MINUTE);
            """
        ).wait()
        
    except Exception as e:
        print(f"Sessionization failed: {e}")
        
if __name__ == "__main__":
    log_processing()