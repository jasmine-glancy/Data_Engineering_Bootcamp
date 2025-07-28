CREATE TABLE hosts_cumulated (
	user_id NUMERIC,
	device_id NUMERIC,
	referrer TEXT,
	host TEXT,

	-- The list of dates the host is experiencing any activity
	host_activity_datelist DATE[],

	-- The current date for the user 
	date DATE,
	PRIMARY KEY(user_id, date)
);