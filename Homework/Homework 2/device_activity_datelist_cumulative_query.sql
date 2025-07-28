-- A cumulative query to generate device_activity_datelist from events
INSERT INTO user_devices_cumulated 
WITH deduped AS (
	SELECT 
		e.user_id AS user_id,
		e.event_time AS event_time,
		d.browser_type AS browser_type,
		d.browser_version_major AS browser_version_major, 
		d.browser_version_minor AS browser_version_minor,
		d.browser_version_patch AS browser_version_patch,
		ROW_NUMBER() OVER (PARTITION BY e.user_id ORDER BY e.user_id) AS row_num
	FROM events e
		LEFT JOIN devices d
		ON d.device_id = e.device_id
),
 	yesterday AS (
		SELECT * FROM user_devices_cumulated
	
		-- Date can be manually filled in
		WHERE date = DATE('2023-01-30')
	
		-- Filter out NULL results
		AND user_id IS NOT NULL
	),
	today AS (
		-- Get all the active users for this day
		
		SELECT
			user_id,
			
			-- Shows the browser type and version from the devices table
			browser_type || ' (' || browser_version_major || '.' || browser_version_minor || '.' || browser_version_patch || ')' AS browser_type,
			DATE(CAST(event_time AS TIMESTAMP)) AS date_active,
			DATE(CAST(event_time AS TIMESTAMP)) AS date
		FROM deduped
		WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE('2023-01-31')
		AND row_num = 1
		-- Filter out NULL results
		AND user_id IS NOT NULL
	)


SELECT
	COALESCE(t.user_id, y.user_id) AS user_id,
	COALESCE(t.browser_type, y.browser_type) AS browser_type,

	-- Fill in device_activity_datelist
	CASE WHEN y.device_activity_datelist IS NULL
		THEN ARRAY[t.date_active]
	WHEN t.date_active IS NULL THEN y.device_activity_datelist
	ELSE ARRAY[t.date_active] || y.device_activity_datelist
	END AS device_activity_datelist,
	
	COALESCE(t.date, y.date) AS date
FROM today t
	FULL OUTER JOIN yesterday y
	ON t.user_id = y.user_id;
