-- The incremental query to generate host_activity_datelist
INSERT INTO hosts_cumulated 
WITH deduped AS (
    -- Deduplicate records
	SELECT 
		user_id,
		device_id,
		referrer,
		host, 
		event_time,
		ROW_NUMBER() OVER (PARTITION BY user_id, DATE(CAST(event_time AS TIMESTAMP)) ORDER BY event_time) AS row_num
	FROM events 
),
 	yesterday AS (
		SELECT * FROM hosts_cumulated 
	
		-- Date can be manually filled in
		WHERE date = DATE('2023-01-04')
	
		-- Filter out NULL results
		AND user_id IS NOT NULL
	),
	today AS (
		-- Get all the active users for this day
		
		SELECT
			user_id,
			device_id,
			referrer,
			host,
			DATE(CAST(event_time AS TIMESTAMP)) AS date_active,
			DATE(CAST(event_time AS TIMESTAMP)) AS date
		FROM deduped
		WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-05')
		AND row_num = 1
		-- Filter out NULL results
		AND user_id IS NOT NULL
	)


SELECT
	COALESCE(t.user_id, y.user_id) AS user_id,
	COALESCE(t.device_id, y.device_id) AS device_id,
	COALESCE(t.referrer, y.referrer) AS referrer,
	COALESCE(t.host, y.host) AS host,

	-- Fill in device_activity_datelist
	CASE WHEN y.host_activity_datelist IS NULL
		THEN ARRAY[t.date_active]
	WHEN t.date_active IS NULL THEN y.host_activity_datelist
	ELSE ARRAY[t.date_active] || y.host_activity_datelist
	END AS host_activity_datelist,
	
	COALESCE(t.date, y.date) AS date
FROM today t
	FULL OUTER JOIN yesterday y
	ON t.user_id = y.user_id;