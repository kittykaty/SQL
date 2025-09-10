-- Product Pathing Analysis


-- STEP 1: pre_product and post_product timeframes
-- STEP 2: sessions that hit the /products
-- STEP 3: sessons that hit the /products and leave/stay
-- STEP 4: case of sessions to_mrfuzzy, to_lovebear

USE mavenfuzzyfactory;
-- New product launch: '2013-01-06': Pre_Product: '2013-01-06' - 3 months, Post_product: '2013-01-06' + 3 months
CREATE TEMPORARY TABLE time_period_w_session
SELECT
		CASE
		WHEN created_at BETWEEN DATE_SUB('2013-01-06', INTERVAL 3 MONTH) AND '2013-01-06' THEN 'A.Pre_Product_2'
		WHEN created_at BETWEEN '2013-01-06'AND DATE_ADD('2013-01-06', INTERVAL 3 MONTH) THEN 'B.Post_Product_2'
    END AS time_period,
    website_session_id
FROM website_pageviews
WHERE created_at BETWEEN DATE_SUB('2013-01-06', INTERVAL 3 MONTH) AND DATE_ADD('2013-01-06', INTERVAL 3 MONTH)
-- AND pageview_url = '/products';



-- STEP 2: sessions that hit the /product
DROP TEMPORARY TABLE products_sessions;
CREATE TEMPORARY TABLE products_sessions
SELECT 
	tpws.time_period,
	wp.website_session_id
FROM website_pageviews wp
JOIN time_period_w_session tpws
ON wp.website_session_id=tpws.website_session_id
WHERE wp.pageview_url = '/products';

SELECT * FROM products_sessions;

SELECT pageview_url, COUNT(*) from website_pageviews
GROUP by 1;

-- sessions that go to next page
CREATE TEMPORARY TABLE products_next_page
SELECT
	DISTINCT ps.website_session_id,
    wp.pageview_url
	-- MIN(wp.website_pageview_id) AS next_pg_view_id
FROM products_sessions ps
JOIN website_pageviews wp
ON ps.website_session_id=wp.website_session_id
WHERE wp.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');


-- FINAL
SELECT
	ps.time_period,
    COUNT(DISTINCT ps.website_session_id) AS sessions, -- sessions that hit the /product
    COUNT(DISTINCT pnp.website_session_id) AS w_next_pg, -- 
    COUNT(DISTINCT pnp.website_session_id)/COUNT(ps.website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN pnp.pageview_url = '/the-original-mr-fuzzy' THEN pnp.website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN pnp.pageview_url = '/the-original-mr-fuzzy' THEN pnp.website_session_id ELSE NULL END)/COUNT(pnp.website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN pnp.pageview_url = '/the-forever-love-bear' THEN pnp.website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN pnp.pageview_url = '/the-forever-love-bear' THEN pnp.website_session_id ELSE NULL END)/COUNT(pnp.website_session_id) AS pct_to_lovebear
FROM products_sessions ps
LEFT JOIN products_next_page pnp
ON ps.website_session_id=pnp.website_session_id
GROUP BY 1;



-- Instructor solution
-- 1: find the relevant/products pageviews with website_session_id
-- 2: find the next pageview_id that occurs after the product pageview
-- 3: find the pageview_url associated with any applicable next pageview id
-- 4: summary the data

-- 1 
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'A.Pre_Product_2'
        WHEN created_at >= '2013-01-06' THEN 'B.Post_Product_2'
	END AS time_period
FROM website_pageviews
WHERE created_at < '2013-04-06'
AND created_at > '2012-10-06'
AND pageview_url = '/products';

-- 2
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT
	p.time_period,
    p.website_session_id,
    MIN(wp.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews p
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id=p.website_session_id
        AND wp.website_pageview_id > p.website_pageview_id
GROUP BY 1,2;

-- 3
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT
	s.time_period,
    s.website_session_id,
    wp.pageview_url AS next_pageview_url
FROM sessions_w_next_pageview_id s
	LEFT JOIN website_pageviews wp
		ON wp.website_pageview_id=s.min_next_pageview_id;
        
select distinct next_pageview_url FROM sessions_w_next_pageview_url;

-- FINAL
SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions, -- sessions that hit the /product
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg, 
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(website_session_id) AS pct_to_lovebear
FROM sessions_w_next_pageview_url
GROUP BY 1;


