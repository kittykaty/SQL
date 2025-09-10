-- CROSS CHANNEL BID OPTIMIZATION

SELECT
	ws.device_type,
    ws.utm_source,
    COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)/COUNT(ws.website_session_id) AS conv_rate

FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id

WHERE
	ws.created_at > '2012-08-22'
    AND ws.created_at < '2012-09-19'
    AND utm_campaign = 'nonbrand'

GROUP BY device_type, utm_source;