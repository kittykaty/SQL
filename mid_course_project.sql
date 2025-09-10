-- Mid-course project
USE mavenfuzzyfactory;

-- 1: monthly trends for gsearch sessions and orders to showcase the growth
SELECT 
	MONTH(ws.created_at) AS month,
    COUNT(DISTINCT ws.website_session_id) AS gsearch_sessions,
    COUNT(CASE WHEN o.order_id IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
        AND ws.utm_source='gsearch'
WHERE ws.created_at < '2012-11-27'
GROUP BY 1;



-- 2: splitting out nonbrand and brand campaigns
SELECT 
	MONTH(ws.created_at) AS month,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(CASE WHEN utm_campaign = 'nonbrand' AND o.order_id IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS nonbrand_orders,
    COUNT(CASE WHEN utm_campaign = 'brand' AND o.order_id IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS brand_orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
        AND ws.utm_source='gsearch'
WHERE ws.created_at < '2012-11-27'
GROUP BY 1;


-- 3: gsearch nonbrand by device type
SELECT 
	MONTH(ws.created_at) AS month,
    COUNT(CASE WHEN ws.device_type='desktop' THEN ws.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN ws.device_type='desktop' AND o.order_id IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS desktop_orders,
    COUNT(CASE WHEN ws.device_type='mobile' THEN ws.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(CASE WHEN ws.device_type='mobile' AND o.order_id IS NOT NULL THEN ws.website_session_id ELSE NULL END) AS mobile_orders
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
WHERE ws.created_at < '2012-11-27'
	AND ws.utm_source='gsearch'
	AND ws.utm_campaign='nonbrand'
GROUP BY 1;

-- 4: traffic for each of channels
SELECT 
	MONTH(created_at) AS month,
    COUNT(CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS gsearch_traffic,
    COUNT(CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS bsearch_traffic,
    COUNT(CASE WHEN utm_source IS NULL THEN website_session_id ELSE NULL END) AS organic_search,
    COUNT(CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END)/
    (COUNT(CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END)+
    COUNT(CASE WHEN utm_source IS NULL THEN website_session_id ELSE NULL END) +
    COUNT(CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END)) AS prc_of_gsearch
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY 1;


SELECT DISTINCT utm_source
FROM website_sessions
WHERE created_at < '2012-11-27'
;


-- 5: session to order conversion rates by month
SELECT
	YEAR(ws.created_at) AS year,
    MONTH(ws.created_at) AS month,
	COUNT(ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    COUNT(o.order_id)/COUNT(ws.website_session_id) AS cvr
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY 1,2;



-- 6: estimate revenue of gsearch lander test

-- find the lander test start date
SELECT
	MIN(created_at) AS test_start_date, -- 2012-06-19 00:35:54, first test pv 23504
    pageview_url
FROM website_pageviews
WHERE created_at < '2012-11-27'
AND pageview_url='/lander-1';

-- first pageviews
DROP TEMPORARY TABLE first_pageview;
CREATE TEMPORARY TABLE first_pageview
SELECT
	DISTINCT wp.website_session_id,
    MIN(wp.website_pageview_id) AS first_pageview_id
FROM website_pageviews wp
	INNER JOIN website_sessions ws
		ON ws.website_session_id=wp.website_session_id
		AND ws.created_at BETWEEN '2012-06-19' AND '2012-07-28' -- test timeperiod
        AND wp.website_pageview_id >= 23504 -- first page_view
		AND utm_source = 'gsearch'
		AND utm_campaign='nonbrand'
GROUP BY 1
;  

SELECT * FROM first_pageview;

-- first pageview_urls by Instructor:
DROP TEMPORARY TABLE test_sessions_w_landing_pages;
CREATE TEMPORARY TABLE test_sessions_w_landing_pages;
SELECT
	fp.website_session_id,
    wp.pageview_url AS landing_page
FROM first_pageview fp
	LEFT JOIN website_pageviews wp
		ON wp.website_pageview_id=fp.first_pageview_id
WHERE wp.pageview_url IN ('/home', '/lander-1');

-- sessions w orders
CREATE TEMPORARY TABLE test_sessions_w_orders
SELECT
	t.website_session_id,
    t.landing_page,
    o.order_id
    FROM test_sessions_w_landing_pages t
    LEFT JOIN orders o
		ON t.website_session_id=o.website_session_id
;

-- find the difference between conversion rates
SELECT
	landing_page,
    COUNT(website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id)/COUNT(website_session_id) AS conv_rate
FROM test_sessions_w_orders
GROUP BY 1;



-- first pageview_urls
DROP TEMPORARY TABLE first_pageview_url;
CREATE TEMPORARY TABLE first_pageview_url1
SELECT
	wp.website_session_id,
    wp.pageview_url,
    fp.first_created_at,
    fp.first_pageview_id
FROM website_pageviews wp
	JOIN first_pageview fp
    ON wp.website_pageview_id=fp.first_pageview_id;
    
-- first pageview_url + gsearch nonbrand
CREATE TEMPORARY TABLE first_pageview_url
SELECT
	fp.website_session_id,
    fp.pageview_url,
    fp.first_created_at,
    fp.first_pageview_id
FROM first_pageview_url1 fp
	JOIN website_sessions ws
	ON ws.website_session_id=fp.website_session_id
	AND utm_source = 'gsearch'
	AND utm_campaign='nonbrand'
;

-- increase in CVR from Jun 19 to Jul 28
SELECT
	MIN(DATE(fp.first_created_at)) AS week_start_date,
    COUNT(DISTINCT fp.website_session_id) AS sessions,
    COUNT(CASE WHEN fp.pageview_url='/lander-1' THEN fp.website_session_id ELSE NULL END) AS lander_sessions,
    COUNT(o.order_id) AS orders,
    SUM(o.price_usd) AS revenue,
	COUNT(o.order_id)/COUNT(DISTINCT fp.website_session_id) AS CVR
FROM first_pageview_url fp
	LEFT JOIN orders o
		ON fp.website_session_id=o.website_session_id
GROUP BY YEARWEEK(fp.first_created_at)
;

-- monthly increase in CVR from Jun 19 to Jul 28
CREATE TEMPORARY TABLE lander_test;
SELECT
	MONTH(fp.first_created_at) AS month,
    COUNT(DISTINCT fp.website_session_id) AS sessions,
    COUNT(CASE WHEN fp.pageview_url='/lander-1' THEN fp.website_session_id ELSE NULL END) AS lander_sessions,
    COUNT(o.order_id) AS orders,
    SUM(o.price_usd) AS revenue,
	COUNT(o.order_id)/COUNT(DISTINCT fp.website_session_id) AS CVR
FROM first_pageview_url fp
	LEFT JOIN orders o
		ON fp.website_session_id=o.website_session_id
GROUP BY 1
;

-- calculate incremental value
SELECT
	MONTH(ws.created_at) AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(o.order_id) AS orders,
    SUM(o.price_usd) AS revenue,
	COUNT(o.order_id)/COUNT(DISTINCT ws.website_session_id) AS CVR
	-- AS incremental_value
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
       /* AND utm_source='gsearch'
		AND utm_campaign='nonbrand' */
WHERE ws.created_at BETWEEN '2012-08-1' AND '2012-11-27'
GROUP BY 1;


-- 7: full conversion funnel from /home and /lander-1


-- funnel steps
SELECT DISTINCT pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-19' AND '2012-07-28';

CREATE TEMPORARY TABLE funnel_steps_by_session
SELECT
	website_session_id,
    MAX(CASE WHEN pageview_url='/home' THEN 1 ELSE 0 END) AS home,
    MAX(CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END) AS lander,
    MAX(CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END) AS products,
    MAX(CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy,
    MAX(CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END) AS cart,
    MAX(CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END) AS shipping,
    MAX(CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END) AS billing,
    MAX(CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou
FROM website_pageviews
WHERE created_at BETWEEN '2012-06-19' AND '2012-07-28'
GROUP BY 1;

SELECT

    CASE
		WHEN home=1 THEN 'home_session'
        WHEN lander=1 THEN 'lander_session'
        ELSE 'check logic'
	END AS sessions,
    SUM(home) AS home_sessions,
    SUM(lander) AS lander_sessions,
    SUM(products)/COUNT(website_session_id) AS cvr_to_products,
    SUM(mrfuzzy)/SUM(products) AS cvr_to_mrfuzzy,
    SUM(cart)/SUM(mrfuzzy) AS cvr_to_cart,
    SUM(shipping)/SUM(cart) AS cvr_to_shipping,
    SUM(billing)/SUM(shipping) AS cvr_to_billing,
    SUM(thankyou)/SUM(billing) AS cvr_to_thankyou
FROM funnel_steps_by_session
GROUP BY 1;


-- 8: revenue per billing session sep 10 - nov 10
SELECT
    -- MONTH(wp.created_at) AS month,
    CASE
		WHEN wp.pageview_url='/billing' THEN 'billing'
        WHEN wp.pageview_url='/billing-2' THEN 'billing-test'
	END AS page,
    COUNT(wp.website_session_id) AS sessions,
    SUM(o.price_usd)/COUNT(wp.website_session_id) AS revenue_per_billing_page_session
FROM website_pageviews wp
	LEFT JOIN orders o
		ON wp.website_session_id=o.website_session_id
WHERE wp.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND wp.pageview_url IN ('/billing', '/billing-2')
GROUP BY 1;

-- $22.83 per old billing page
-- $31.34 per new billing page
-- LIFT: 8.51$ per billing page view

SELECT
	COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews
WHERE pageview_url IN ('/billing', '/billing-2')
AND created_at BETWEEN '2012-10-27' AND '2012-11-27';

-- 1193 billing sessions past month
-- LIFT: $8.51
-- VALUE OF BILLING TEST: $10,160 over the past month








