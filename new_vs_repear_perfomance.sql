-- new vs. repeat perfomance

SELECT
	ws.is_repeat_session,
    COUNT(ws.website_session_id) AS sessions,
	COUNT(o.order_id)/COUNT(ws.website_session_id) AS conv_rate,
	SUM(o.price_usd)/COUNT(ws.website_session_id) AS rev_per_session
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1;