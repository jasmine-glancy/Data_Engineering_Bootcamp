-- A monthly, reduced fact table DDL host_activity_reduced
CREATE TABLE host_activity_reduced (
    date DATE,
    month_start DATE,
    host TEXT,

    -- COUNT(1)
    site_hits REAL[],

    -- COUNT(DISTINCT user_id)
    unique_visitors REAL[]
);