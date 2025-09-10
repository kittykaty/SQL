-- BUILDING CONVERSION FUNNELS

-- step 1: select all pageviews for relevant sessions
-- step 2: identify each relevant pageview as the specific funnel step
-- step 3: create the session_level_conversion funnect view
-- step 4: aggregate the data to assess funnel perfomance
CREATE TEMPORARY TABLE funnel_perfomance
SELECT
	website_session_id,
    MAX(sessions) AS sessions,
    MAX(to_products) AS to_products,
    MAX(to_mrfuzzy) AS to_mrfuzzy,
    MAX(to_cart) AS to_cart,
    MAX(to_shipping) AS to_shipping,
    MAX(to_billing) AS to_billing,
    MAX(to_thankyou) AS to_thankyou
FROM (
SELECT
	wp.website_session_id,
    wp.created_at,
	wp.pageview_url,
   -- funnel steps
   CASE WHEN wp.pageview_url='/lander-1' THEN 1 ELSE 0 END AS sessions,
   CASE WHEN wp.pageview_url='/products' THEN 1 ELSE 0 END AS to_products,
   CASE WHEN wp.pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS to_mrfuzzy,
   CASE WHEN wp.pageview_url='/cart' THEN 1 ELSE 0 END AS to_cart,
   CASE WHEN wp.pageview_url='/shipping' THEN 1 ELSE 0 END AS to_shipping,
   CASE WHEN wp.pageview_url='/billing' THEN 1 ELSE 0 END AS to_billing,
   CASE WHEN wp.pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS to_thankyou
FROM website_pageviews wp
JOIN website_sessions ws
ON wp.website_session_id=ws.website_session_id
WHERE ws.created_at < '2012-09-05'
AND ws.created_at > '2012-08-05'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand') as funnel_table

GROUP BY website_session_id;


-- FINAL 1:
SELECT 
	SUM(sessions) AS sessions,
	SUM(to_products) AS to_products,
    SUM(to_mrfuzzy) AS to_mrfuzzy,
    SUM(to_cart) AS to_cart,
    SUM(to_shipping) AS to_shipping,
    SUM(to_billing) AS to_billing,
    SUM(to_thankyou) AS to_thankyou
FROM funnel_perfomance;
    
-- FINAL 2    
SELECT
    SUM(to_products)/SUM(sessions) AS lander_click_rt,
	SUM(to_mrfuzzy)/SUM(to_products) AS products_click_rt,
	SUM(to_cart)/SUM(to_mrfuzzy) AS mrfuzzy_click_rt,
	SUM(to_shipping)/SUM(to_cart) AS cart_click_rt,
    SUM(to_thankyou)/SUM(to_shipping) AS shipping_click_rt
FROM funnel_perfomance;