/* For cross-verifying the Flink output against our Source of Truth */

-- 1. Count events in a session by host and IP

SELECT
    ip,
    host,
    COUNT(*) AS session_event_count
FROM process_events_kafka
GROUP BY
  ip,
  host
  
-- 2. Calculate average session events for specific hosts
WITH sessionized AS (
	SELECT
        ip,
	    host,
	    COUNT(*) AS session_event_count
	FROM processed_events
	GROUP BY
	  ip,
	  host
)

SELECT 
	host,
	AVG(session_event_count) AS avg_events_per_session
FROM sessionized
GROUP BY host;
