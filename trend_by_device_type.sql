SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS mob_session
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND created_at > '2012-04-15'
	AND utm_source='gsearch'
    AND utm_campaign='nonbrand'
GROUP BY WEEK(created_at)