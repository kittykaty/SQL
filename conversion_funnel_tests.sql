-- ANALYSING CONVERSION FUNNEL TESTS

-- step 1: find the first time /billing-2 was seen
SELECT
	MIN(website_pageview_id), -- 535550
    MIN(created_at) -- 2012-09-10 00:13:05
FROM website_pageviews 
WHERE pageview_url = '/billing-2';


-- step 2: session landed on billing page and orders page
SELECT
	website_session_id,
    MAX(billing_A),
    MAX(billing_B)
FROM (
SELECT
	website_session_id,
    CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END as billing_A,
    CASE WHEN pageview_url='/billing-2' THEN 1 ELSE 0 END as billing_B
FROM website_pageviews
WHERE created_at < '2012-11-10'
AND website_session_id >= 25325
) AS billing_tests
GROUP BY 1;


-- sessions on /billing and /billing-2
DROP TEMPORARY TABLE billing_page_landing;
CREATE TEMPORARY TABLE billing_page_landing
SELECT
	website_session_id,
    pageview_url
FROM website_pageviews
WHERE created_at < '2012-11-10'
AND website_pageview_id >= 53550
AND pageview_url IN ('/billing', '/billing-2');

SELECT * FROM billing_page_landing;

-- which sessions from billing_page_landing got to the '/thank-you-for-your-order' page
DROP TEMPORARY TABLE orders_page_landing;
CREATE TEMPORARY TABLE orders_page_landing
SELECT
	bpl.website_session_id,
	wp.pageview_url
FROM billing_page_landing bpl
JOIN website_pageviews wp
ON bpl.website_session_id=wp.website_session_id
WHERE wp.pageview_url='/thank-you-for-your-order';



SELECT 
	COUNT(website_session_id),
    pageview_url
FROM billing_page_landing
GROUP BY pageview_url;



-- FINAL
SELECT
	bpl.pageview_url AS billing_version_seen,
    COUNT(bpl.website_session_id) AS sessions,
    COUNT(opl.website_session_id) AS orders,
    COUNT(opl.website_session_id)/COUNT(bpl.website_session_id) AS billing_to_order_rt
FROM
billing_page_landing bpl
LEFT JOIN orders_page_landing opl
ON opl.website_session_id=bpl.website_session_id
GROUP BY 1;