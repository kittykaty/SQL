-- Analyzing channel portfolios

SELECT
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions

FROM website_sessions 
WHERE created_at < '2012-11-29'
AND created_at > '2012-08-22'
AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);


SELECT * FROM website_sessions;