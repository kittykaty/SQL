-- ANALYZING BUSINESS PATTERNS

-- OPTION 1:

SELECT
	HOUR(created_at) AS hr,
    COUNT(CASE WHEN WEEKDAY(created_at) = 0 THEN website_session_id ELSE NULL END) AS mon,
    COUNT(CASE WHEN WEEKDAY(created_at) = 1 THEN website_session_id ELSE NULL END) AS tue,
    COUNT(CASE WHEN WEEKDAY(created_at) = 2 THEN website_session_id ELSE NULL END) AS wed,
    COUNT(CASE WHEN WEEKDAY(created_at) = 3 THEN website_session_id ELSE NULL END) AS thu,
    COUNT(CASE WHEN WEEKDAY(created_at) = 4 THEN website_session_id ELSE NULL END) AS fri,
    COUNT(CASE WHEN WEEKDAY(created_at) = 5 THEN website_session_id ELSE NULL END) AS sat,
    COUNT(CASE WHEN WEEKDAY(created_at) = 6 THEN website_session_id ELSE NULL END) AS sun
FROM website_sessions
WHERE created_at > '2012-09-15'
AND created_at < '2012-11-15'
GROUP BY 1;


-- AVERAGE

SELECT
    hr,
    ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END),1) AS tue,
    ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END),1) AS wed,
    ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) AS thu,
    ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END),1) AS fri,
    ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END),1) AS sat,
    ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END),1) AS sun
FROM(
SELECT
	DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3)
AS daily_hourly_sessions
GROUP BY 1
ORDER BY 1;