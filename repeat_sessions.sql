-- analyzing repeat behavior

-- 1: select sessions 1st and 2nd session time and difference between them
CREATE TEMPORARY TABLE first_ses
SELECT
	user_id,
    CASE WHEN is_repeat_session = 0 THEN created_at ELSE NULL END AS first_session_time
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03';

-- second session time
CREATE TEMPORARY TABLE first_and_sec_sess
SELECT
	f.user_id,
    f.first_session_time,
	MIN(ws.created_at) AS second_session_time
FROM first_ses f
	LEFT JOIN website_sessions ws
		ON f.user_id = ws.user_id
        AND ws.created_at > f.first_session_time
        AND ws.is_repeat_session = 1
GROUP BY 1,2;


SELECT *
FROM first_and_sec_sess;

SELECT
	AVG(DATEDIFF(second_session_time, first_session_time))AS avg_days_first_to_second,
    MIN(DATEDIFF(second_session_time, first_session_time)) AS min_days_first_to_second,
    MAX(DATEDIFF(second_session_time, first_session_time)) AS max_days_first_to_second
FROM first_and_sec_sess;



-- NEW vs. REPEAT CHANNEL PATTERNS

SELECT DISTINCT
	utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03';


SELECT
	CASE
		WHEN ws.utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN ws.utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
        WHEN ws.utm_campaign='brand' THEN 'paid_brand'
        WHEN ws.utm_campaign ='nonbrand' THEN 'paid_nonbrand'
        WHEN ws.utm_source = 'socialbook' THEN 'paid_social'
    END AS channel_group,
    COUNT(f.first_session_time) AS new_sessions,
    COUNT(f.second_session_time) AS repeat_sessions
FROM first_and_sec_sess f
JOIN website_sessions ws
	ON f.user_id=ws.user_id
GROUP BY 1;


-- instructor solution
SELECT
    CASE
		WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN 'organic_search'
        WHEN utm_campaign='brand' THEN 'paid_brand'
        WHEN utm_campaign ='nonbrand' THEN 'paid_nonbrand'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
    END AS channel_group,
    COUNT(CASE WHEN is_repeat_session=0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session=1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1
ORDER BY 3 DESC;
    
