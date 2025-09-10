-- product conversion funnels

-- STEP 1: sessions landing at product page
-- STEP 2: sessions landing at cart,
-- STEP 3: sessions landing at shipping,
-- STEP 4: sessions landing at billing,
-- STEP 5: sessions landing at thankyou

-- 1: select all pageviews for relevant sessions
-- 2: which pageview urls to look for
-- 3: pull all pageviews and identify the funnel steps
-- 4: create session-level conversion funnel view
-- 5: aggregate funnel perfomance


-- flagging for funnel steps: /products -> /the-original-mr-fuzzy OR /the-forever-love-bear -> /cart -> /shipping -> /billing-2 -> /thank-you-for-your-order
DROP TEMPORARY TABLE funnel_steps_per_session;
CREATE TEMPORARY TABLE funnel_steps_per_session
SELECT
	website_session_id,
    -- pageview_url,
    MAX(CASE WHEN pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear') THEN website_pageview_id ELSE NULL END) AS product,
    MAX(CASE WHEN pageview_url= '/cart' THEN website_pageview_id ELSE NULL END) AS cart,
    MAX(CASE WHEN pageview_url= '/shipping' THEN website_pageview_id ELSE NULL END) AS shipping,
    MAX(CASE WHEN pageview_url= '/billing-2' THEN website_pageview_id ELSE NULL END) AS billing,
    MAX(CASE WHEN pageview_url= '/thank-you-for-your-order' THEN website_pageview_id ELSE NULL END) AS thank_you
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
GROUP BY 1;

SELECT * FROM funnel_steps_per_session;
SELECT * from website_pageviews
WHERE website_session_id = 63513
AND created_at BETWEEN '2013-01-06' AND '2013-04-10';

-- identify what session which product
CREATE TEMPORARY TABLE sessions_by_product
SELECT
	f.website_session_id,
    f.product,
    p.pageview_url
FROM funnel_steps_per_session f
JOIN website_pageviews p
ON f.product=p.website_pageview_id;


-- FINAL 1:
SELECT
	s.pageview_url AS product_seen,
    COUNT(DISTINCT f.website_session_id) AS sessions,
    COUNT(DISTINCT f.cart) AS to_cart,
    COUNT(DISTINCT f.shipping) AS to_shipping,
    COUNT(DISTINCT f.billing) AS to_billing,
    COUNT(DISTINCT f.thank_you) AS to_thankyou
FROM funnel_steps_per_session f
JOIN sessions_by_product s
ON f.product=s.product
GROUP BY 1;

-- FINAL 2:
SELECT
	s.pageview_url AS product_seen,
    COUNT(DISTINCT f.cart)/COUNT(DISTINCT f.website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT f.shipping)/COUNT(DISTINCT f.cart) AS cart_click_rt,
    COUNT(DISTINCT f.billing)/COUNT(DISTINCT f.shipping) AS shipping_click_rt,
    COUNT(DISTINCT f.thank_you)/COUNT(DISTINCT f.billing) AS billing_click_rt
FROM funnel_steps_per_session f
JOIN sessions_by_product s
ON f.product=s.product
GROUP BY 1;




-- 1: select all pageviews for relevant sessions
DROP TEMPORARY TABLE pageviews_for_sessions;
CREATE TEMPORARY TABLE pageviews_for_sessions
SELECT 
	website_session_id,
    website_pageview_id,
    pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear');

-- 2: identify funnel steps!!
SELECT DISTINCT
	w.pageview_url
FROM pageviews_for_sessions p
    LEFT JOIN website_pageviews w
		ON p.website_session_id=w.website_session_id
        AND w.website_pageview_id > p.website_pageview_id;
    

-- 3: pull all pageviews and identify the funnel steps
CREATE TEMPORARY TABLE session_product_level_made_id_flags
SELECT
	p.website_session_id,
    CASE
		WHEN p.pageview_url = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
        WHEN p.pageview_url = '/the-forever-love-bear' THEN 'lovebear'
	END AS product_seen,
    MAX(CASE WHEN w.pageview_url= '/cart' THEN 1 ELSE 0  END) AS cart,
    MAX(CASE WHEN w.pageview_url= '/shipping' THEN 1 ELSE 0 END) AS shipping,
    MAX(CASE WHEN w.pageview_url= '/billing-2' THEN 1 ELSE 0 END) AS billing,
    MAX(CASE WHEN w.pageview_url= '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thank_you
FROM pageviews_for_sessions p
LEFT JOIN website_pageviews w
	ON p.website_session_id=w.website_session_id
        AND w.website_pageview_id > p.website_pageview_id
GROUP BY 1,2;



-- 4: create session-level conversion funnel view
SELECT
	product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(cart) AS to_cart,
    SUM(shipping) AS to_shipping,
    SUM(billing) AS to_billing,
    SUM(thank_you) AS to_thankyou
FROM session_product_level_made_id_flags
GROUP BY 1;
-- 5: aggregate funnel perfomance

