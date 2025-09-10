-- Product launch sales analysis

SELECT 
	YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate,
    ROUND(SUM(price_usd)/COUNT(DISTINCT ws.website_session_id),2) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN o.primary_product_id=1 THEN o.order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN o.primary_product_id=2 THEN o.order_id ELSE NULL END)AS product_two_orders
FROM orders o
RIGHT JOIN website_sessions ws
ON o.website_session_id=ws.website_session_id
WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1,2;


SELECT
	MONTH(ws.created_at),
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM orders o
RIGHT JOIN website_sessions ws
ON o.website_session_id=ws.website_session_id
GROUP BY 1;
