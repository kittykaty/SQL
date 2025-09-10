-- cross-sell-analysis


-- step 1: identify session_id for periods and /cart page views
-- step 2: identify possible next pages for this session_ids
-- step 3: clickthroughs from /cart page to next pages
-- step 4: select products per order and than use it as avg number of orders
-- step 5: average order values
-- step 6: revenue per cart session


-- cross sell products
SELECT
	o.order_id,
	o.primary_product_id,
    oi.product_id AS cross_sell_product
FROM orders o
	LEFT JOIN order_items oi
		ON oi.order_id = o.order_id
        AND oi.is_primary_item = 0 -- cross sell only
        
WHERE o.order_id BETWEEN 10000 AND 11000;

-- time and /cart sessions
CREATE TEMPORARY TABLE cart_sessions_by_period
SELECT
	CASE
		WHEN created_at BETWEEN '2013-08-25' AND '2013-09-25' THEN 'A.Pre_Cross_Sell'
        WHEN created_at BETWEEN '2013-09-25' AND'2013-10-25' THEN 'B.Post_Cross_Sell'
	END AS time_period,
	website_session_id,
    website_pageview_id
FROM website_pageviews
WHERE pageview_url = '/cart'
AND created_at BETWEEN '2013-08-25' AND '2013-10-25';

-- sessions_id for clickthrough the /cart page
DROP TEMPORARY TABLE clickthrough_sessions_id;
CREATE TEMPORARY TABLE clickthrough_sessions_id;
SELECT
	time_period,
	c.website_session_id,
	MAX(CASE WHEN w.website_session_id IS NOT NULL THEN 1 ELSE 0 END) AS clickthroughs
FROM cart_sessions_by_period c
	LEFT JOIN website_pageviews w
		ON c.website_session_id=w.website_session_id
        AND w.website_pageview_id > c.website_pageview_id
GROUP BY 1,2;


-- step 4: select products per order and than use it as avg number of orders
DROP TEMPORARY TABLE sessions_w_orders;
CREATE TEMPORARY TABLE sessions_w_orders
SELECT
	c.time_period,
    c.website_session_id,
    c.clickthroughs,
    o.items_purchased,
    o.price_usd
FROM clickthrough_sessions_id c
	LEFT JOIN orders o
		ON c.website_session_id = o.website_session_id;

SELECT * FROM sessions_w_orders;


-- step 5: average order values
-- step 6: revenue per cart session


-- FINAL
SELECT
	time_period,
    COUNT(website_session_id) AS cart_sessions,
    SUM(clickthroughs) AS clickthroughs,
	SUM(clickthroughs)/COUNT(website_session_id) AS cart_ctr,
    AVG(items_purchased) AS prdocuts_per_order,
    AVG(price_usd) AS aov,
    SUM(price_usd)/COUNT(website_session_id) AS rev_per_cart_session
FROM sessions_w_orders
GROUP BY 1;
    
    
