-- entry pages
/*DROP temporary table first_entry; */

-- STEP 1: finde the first pageview for each session
-- STEP 2: find the url the customer saw on that first pageview

CREATE TEMPORARY TABLE first_entry
SELECT 
	website_session_id,
    MIN(created_at) as entry_time
FROM website_pageviews
WHERE
	created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT * from first_entry;

DROP TEMPORARY TABLE first_entry_by_id;
CREATE TEMPORARY TABLE first_entry_by_id
SELECT 
	website_session_id,
    MIN(website_pageview_id) as entry_id
FROM website_pageviews
WHERE
	created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
	wp.pageview_url AS landing_page,
    COUNT(DISTINCT fe.website_session_id) AS sessions_hiting_this_landing_page
FROM 
	website_pageviews wp
JOIN first_entry_by_id fe
ON wp.website_pageview_id = fe.entry_id
WHERE
	created_at < '2012-06-12'
GROUP BY 1
ORDER BY 2 DESC;