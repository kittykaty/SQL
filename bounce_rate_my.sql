
-- 1: First landing: find the first website_pageview_id for relevant session
DROP TEMPORARY TABLE first_landing;
CREATE TEMPORARY TABLE first_landing
SELECT 
	website_session_id as first_landing,
    MIN(website_pageview_id) as entry_id
FROM website_pageviews
WHERE
	created_at < '2012-06-14'
GROUP BY 1;

SELECT * FROM first_landing;

-- 2: Identify the landing page:
SELECT 
	website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_landing.first_landing) AS sessions
FROM website_pageviews
JOIN first_landing
ON first_landing.entry_id=website_pageviews.website_pageview_id
WHERE
	created_at < '2012-06-14'
GROUP BY 1;

-- 3: Counting pageviews for each session, to identify "bounces"
DROP TEMPORARY TABLE bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions1
SELECT
	website_session_id,
    COUNT(DISTINCT pageview_url) as pageviews
FROM website_pageviews
WHERE
	created_at < '2012-06-14'
GROUP BY website_session_id
HAVING pageviews = 1;

-- 4: Summarize total sessions and bounced sessions
SELECT
	COUNT(DISTINCT first_landing.first_landing) AS sessions,
    COUNT(DISTINCT bounced_sessions1.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions1.website_session_id)/COUNT(DISTINCT first_landing.first_landing) AS bounced_rate
FROM
	first_landing -- or landing page?
LEFT JOIN bounced_sessions1
ON first_landing.first_landing = bounced_sessions1.website_session_id;