-- Create a DDL for a user_devices_cumulated table that 
-- tracks a user's active days by browser_type
CREATE TABLE user_devices_cumulated (
	user_id NUMERIC,
	
	browser_type TEXT,

	-- The list of dates the user was active on this browser_type
	device_activity_datelist DATE[],

	-- The current date for the user 
	date DATE,
	PRIMARY KEY(user_id, date)
);