-- ASSIGNEMNT LANDING PAGE TREND ANALYSIS

-- step 1: select sessions landing to home and lander-1 for specific period and ad campaign;
-- step 2: table with bounced_sessions
-- step 3: bounce_ rate as a separate table?
-- step 4: pivot home, lander weekly
USE mavenfuzzyfactory;
-- first pageview with params
CREATE TEMPORARY TABLE first_pageview1
SELECT 
	wp.website_session_id,
    MIN(wp.website_pageview_id) as min_pageview
FROM website_pageviews wp
JOIN website_sessions ws
ON wp.website_session_id=ws.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND wp.created_at < '2012-08-31'
	AND wp.created_at > '2012-06-01'
GROUP BY 1;


-- first pageview_url = all entry sessions with created_at
DROP TEMPORARY TABLE first_pageview_url;
CREATE TEMPORARY TABLE first_pageview_url
SELECT 
	wp.website_session_id,
    wp.pageview_url,
    wp.created_at
FROM first_pageview1 fp
JOIN website_pageviews wp
ON wp.website_pageview_id=fp.min_pageview
WHERE wp.pageview_url IN ('/home', '/lander-1');

SELECT COUNT(website_session_id), pageview_url FROM first_pageview_url GROUP BY 2;

-- bounce sessions: website_session_id and number of pageviews
DROP TEMPORARY TABLE bounced_sessions_1;
CREATE TEMPORARY TABLE bounced_sessions_1
SELECT 
	fpu.website_session_id,
    fpu.pageview_url AS landing_page,
    COUNT(wp.website_pageview_id) AS number_of_pageviews
FROM website_pageviews wp
JOIN first_pageview_url fpu
ON wp.website_session_id=fpu.website_session_id
GROUP by 1,2
HAVING COUNT(wp.website_pageview_id)=1;


SELECT
	MIN(DATE(fpu.created_at)) AS week_start_date,
	COUNT(bs.website_session_id)/COUNT(fpu.website_session_id) AS bounce_rate,
    COUNT(CASE WHEN fpu.pageview_url='/home' THEN fpu.website_session_id ELSE NULL END) AS home_sessions,
    COUNT(CASE WHEN fpu.pageview_url='/lander-1' THEN fpu.website_session_id ELSE NULL END) AS lander_sessions
FROM
first_pageview_url fpu
LEFT JOIN bounced_sessions_1 bs
ON fpu.website_session_id=bs.website_session_id
GROUP BY WEEK(fpu.created_at);





-- FINAL
SELECT
	MIN(created_at) AS week_start_date,
    AS bounce_rate,
    COUNT(DISTINCT CASE WHEN fpu.pageview_url='/home' THEN website_session_id ELSE NULL END)AS home_sessions,
    COUNT(DISTINCT CASE WHEN fpu.pageview_url='/lander-1' THEN website_session_id ELSE NULL END)AS lander_sessions
FROM
first_pageview_url fpu
LEFT JOIN
GROUP BY WEEK(created_at);