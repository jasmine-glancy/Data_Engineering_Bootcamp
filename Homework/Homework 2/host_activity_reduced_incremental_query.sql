-- An incremental query that loads host_activity_reduced day-by-day
INSERT INTO host_activity_reduced
WITH date_series AS (
	SELECT generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') AS date
),
	host_list AS (
		-- Aggregates the hosts
		SELECT DISTINCT host FROM events
	), 
		dates_by_host AS (
			SELECT ds.date, hl.host
			FROM date_series ds
			CROSS JOIN host_list hl
		),
			daily_aggregate AS (
				SELECT
					dh.host AS host,
					dh.date AS date,
					COUNT(1) AS num_site_hits,
					COUNT(DISTINCT e.user_id) AS num_unique_visitors
				FROM events e
				LEFT JOIN dates_by_host dh
					ON dh.date = DATE(e.event_time)
					AND dh.host = e.host
				WHERE dh.date BETWEEN DATE('2023-01-01') AND DATE('2023-01-31')
			
				-- Filter NULL results
				AND user_id IS NOT NULL
				GROUP BY dh.host, dh.date
			),
				yesterday_array AS (
					SELECT * FROM host_activity_reduced
					WHERE month_start = DATE('2023-01-01')
				)

SELECT 
	COALESCE(ya.date, da.date) AS date,
	COALESCE(ya.month_start, DATE_TRUNC('month', da.date)) AS month_start,
	COALESCE(ya.host, da.host) AS host,
	 -- When everything is empty
    CASE WHEN ya.month_start IS NULL THEN ARRAY[COALESCE(da.num_site_hits, 0)]
	-- If yesterday's site_hits is NOT NULL, then the host information already exists
	WHEN ya.site_hits IS NOT NULL THEN
	-- COALESCE to retun 0 instead of NULL if num_site_hits is NULL
		ya.site_hits || ARRAY[COALESCE(da.num_site_hits, 0)]
	WHEN ya.site_hits IS NULL THEN
		ARRAY[COALESCE(da.num_site_hits, 0)]
	END AS site_hits,

	 -- When everything is empty
    CASE WHEN ya.month_start IS NULL THEN ARRAY[COALESCE(da.num_unique_visitors, 0)] 
	-- If yesterday's visitors is NOT NULL, then the host information already exists
	WHEN ya.unique_visitors IS NOT NULL THEN
	-- COALESCE to retun 0 instead of NULL if num_site_hits is NULL
		ya.unique_visitors || ARRAY[COALESCE(da.num_unique_visitors, 0)]
	WHEN ya.unique_visitors IS NULL THEN
		ARRAY[COALESCE(da.num_unique_visitors, 0)]
	END AS unique_visitors
	
FROM daily_aggregate da
LEFT JOIN yesterday_array ya
	ON da.date = ya.date
GROUP BY
	COALESCE(ya.date, da.date),
	ya.month_start,
	da.date,
	COALESCE(ya.host, da.host),
	da.num_site_hits,
	ya.site_hits,
	da.num_unique_visitors,
	ya.unique_visitors;

	SELECT * FROM host_activity_reduced