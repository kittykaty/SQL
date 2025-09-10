-- ANALYZING SEASONALITY

-- MONTHLY VOLUME
SELECT
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id
WHERE ws.created_at < '2013-01-02'
GROUP BY 1,2;


-- WEEKLY VOLUME
SELECT
	MIN(DATE(ws.created_at)) AS week_start_date,
    COUNT(DISTINCT ws.website_session_id)AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id
WHERE ws.created_at < '2013-01-02'
GROUP BY WEEK(ws.created_at);
