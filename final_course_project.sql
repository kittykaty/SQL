-- final cource project


-- 1: show volume growth: session and order volume trended by quarter
SELECT
	YEAR(ws.created_at) as year,
    QUARTER(ws.created_at) as quarter,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
GROUP BY 1, 2;


-- 2: quarterly session-to-order cvr, rev per order, rev per session
SELECT
	YEAR(ws.created_at) as year,
    QUARTER(ws.created_at) as quarter,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS session_to_order,
    SUM(o.price_usd)/COUNT(DISTINCT o.order_id) revenue_per_order,
    SUM(o.price_usd)/COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
GROUP BY 1, 2;

-- 3: quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search and direct type-in
SELECT
	YEAR(ws.created_at) as year,
    QUARTER(ws.created_at) as quarter,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) AS gsearch_nonbrand_orders,
    COUNT(CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
    COUNT(CASE WHEN utm_campaign='brand' THEN o.order_id ELSE NULL END) AS brand_orders,
    COUNT(CASE WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END) AS direct_type_in_orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
GROUP BY 1, 2
;


-- 4 Session-to-order conversion rate trends for channels by quarter
SELECT
	YEAR(ws.created_at) as year,
    QUARTER(ws.created_at) as quarter,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS cvr,
    COUNT(CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN o.order_id ELSE NULL END)/
    COUNT(CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN ws.website_session_id ELSE NULL END) AS gsearch_nonbrand_cvr,
    
    COUNT(CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN o.order_id ELSE NULL END)/
    COUNT(CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN ws.website_session_id ELSE NULL END) AS bsearch_nonbrand_cvr,
    
    COUNT(CASE WHEN utm_campaign='brand' THEN o.order_id ELSE NULL END)/COUNT(CASE WHEN utm_campaign='brand' THEN ws.website_session_id ELSE NULL END) AS brand_cvr,
    
    COUNT(CASE WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NOT NULL THEN o.order_id ELSE NULL END)/
    COUNT(CASE WHEN utm_source IS NULL AND utm_campaign IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS organic_search_cvr,
    
    COUNT(CASE WHEN http_referer IS NULL THEN o.order_id ELSE NULL END)/COUNT(CASE WHEN http_referer IS NULL THEN ws.website_session_id ELSE NULL END) AS direct_type_in_cvr
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
GROUP BY 1, 2
;

