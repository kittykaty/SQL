-- Assignment: analyzing landing page tests

-- STEP 1: Timeframe of LP tess
-- STEP 2: Sessions with landing page at /home page
-- STEP 3: Sessions with landing page at /lander-1 page
-- STEP 4: Bounced sessions of /home page
-- STEP 5: Bounced sessions of /lander-1 page
-- STEP 6: Final output with bounce_rate

-- finding the first instance of /lander-1 to set analysis timeframe
SELECT
		MIN(created_at) AS first_created_at, -- 2012-06-19
        MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
AND created_at < '2012-07-28';

-- Landing sessions:
DROP TEMPORARY TABLE first_pageviews;
CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageview_id) as min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id=website_pageviews.website_session_id
        AND website_sessions.created_at <'2012-07-28'
        AND website_pageviews.created_at >= '2012-06-19 00:35:54' -- website_pageview instead website_sessions!
        AND utm_source ='gsearch'
        AND utm_campaign='nonbrand'
-- WHERE
	-- created_at >= '2012-06-19 00:35:54'
	-- AND created_at < '2012-07-28'
GROUP BY 1;

SELECT * FROM first_pageviews;

-- Landing page
DROP TEMPORARY TABLE landing_page_url;
CREATE TEMPORARY TABLE landing_page_url
SELECT
	fp.website_session_id,
    wp.pageview_url AS landing_page
FROM website_pageviews wp
JOIN first_pageviews fp
ON wp.website_pageview_id=fp.min_pageview_id
WHERE wp.pageview_url IN ('/home', '/lander-1');

SELECT * FROM landing_page_url;

-- Bounced sessions with landign page
DROP TEMPORARY TABLE bounced_sessions_w_lp;
CREATE TEMPORARY TABLE bounced_sessions_w_lp
SELECT
	lp.landing_page,
	lp.website_session_id,
    COUNT(wp.website_pageview_id) AS count_of_pageviews
FROM landing_page_url lp
JOIN website_pageviews wp
ON lp.website_session_id=wp.website_session_id
GROUP BY 1,2
HAVING COUNT(wp.website_pageview_id) = 1;

SELECT * FROM bounced_sessions_w_lp;


-- FINAL OUTPUT
SELECT
	lp.landing_page AS landing_page,
	COUNT(DISTINCT lp.website_session_id) AS total_sessions,
    COUNT(DISTINCT bs.website_session_id) AS bounced_sessions,
    COUNT(bs.website_session_id)/COUNT(lp.website_session_id) AS bounce_rate
FROM
	landing_page_url lp
LEFT JOIN 
	bounced_sessions_w_lp bs
ON lp.website_session_id=bs.website_session_id
GROUP BY 1;

-- FINAL OUTPUT
/*
WITH sessions AS
(SELECT landing_page, count(website_session_id) AS sessions_by_page FROM landing_page_url GROUP BY landing_page),
bounced AS 
(SELECT landing_page, COUNT(website_session_id) AS bounce_by_page from bounced_sessions_w_lp GROUP BY landing_page)

SELECT 
	s.landing_page AS landing_page,
    s.sessions_by_page AS total_sessions,
	b.bounce_by_page AS bounced_sessions,
    b.bounce_by_page/s.sessions_by_page AS bounce_rate
FROM sessions s
JOIN bounced b
ON s.landing_page=b.landing_page;
*/


