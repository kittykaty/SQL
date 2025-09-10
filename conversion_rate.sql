SELECT 
	COUNT(DISTINCT ws.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as orders,
	COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) as session_to_order_conv_rate
FROM website_sessions ws
LEFT JOIN orders o
ON ws.website_session_id=o.website_session_id
WHERE ws.created_at < '2012-04-14'
AND ws.utm_source = 'gsearch'
AND ws.utm_campaign = 'nonbrand'