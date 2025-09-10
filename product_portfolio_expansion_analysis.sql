-- product portfolio expansion analysis


-- 1: sessions in time period
-- 2: sessions in time period with/without order
-- 3: aggregate
CREATE TEMPORARY TABLE sessions
SELECT
	CASE
		WHEN created_at BETWEEN '2013-11-12' AND '2013-12-12' THEN 'A.Pre_Birthday_Bear'
        WHEN created_at BETWEEN '2013-12-12' AND '2014-01-12' THEN 'B.Post_Birthday_Bear'
    END AS time_period,
    website_session_id
FROM website_sessions
WHERE
	created_at BETWEEN '2013-11-12' AND '2014-01-12';
    
-- sessions in time period with/without order
SELECT
	s.time_period,
    s.website_session_id AS sessions,
    o.order_id AS orders,
    o.items_purchased,
    o.price_usd
FROM sessions s
	LEFT JOIN orders o
		ON s.website_session_id = o.website_session_id;



SELECT
	time_period,
    COUNT(orders)/COUNT(sessions) AS cov_rate,
    AVG(price_usd) AS aov,
    SUM(price_usd)/COUNT(DISTINCT orders) AS aov_check,
    AVG(items_purchased) AS products_per_order,
    SUM(price_usd)/COUNT(sessions) AS revenue_per_session
FROM
(
SELECT
	s.time_period,
    s.website_session_id AS sessions,
    o.order_id AS orders,
    o.items_purchased,
    o.price_usd
FROM sessions s
	LEFT JOIN orders o
		ON s.website_session_id = o.website_session_id
) AS sessions_w_orders
GROUP BY 1;