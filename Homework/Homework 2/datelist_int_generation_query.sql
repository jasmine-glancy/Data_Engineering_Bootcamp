-- A datelist_int generation query. Convert the device_activity_datelist column into a datelist_int column
WITH users AS (
    -- After filling user_devices_cumulated, select the latest value for the "current date"
	SELECT * FROM user_devices_cumulated
	WHERE date = DATE('2023-01-31')
),
	series AS (
        -- Generate a date series
		SELECT *
		FROM generate_series(DATE('2023-01-02'), DATE('2023-01-31'), INTERVAL '1 day') AS series_date
	),
	datelist_ints AS (
	    SELECT CASE 
            WHEN
                -- @> means "contains". See if the series is within the active array
                device_activity_datelist @> ARRAY [DATE(series_date)]
            -- Converts all dates into integer values with the power of 2
            THEN POW(2, 32 - CAST((date - DATE(series_date)) AS BIGINT))
                ELSE 0
                    END AS datelist_int,

            *
        FROM users CROSS JOIN series
        WHERE user_id = '332725596441622800'
	)
	
SELECT 
    user_id,
	
    -- Shows the datelist 
    CAST(CAST(SUM(datelist_int) AS BIGINT) AS BIT(32))
FROM datelist_ints
GROUP BY user_id