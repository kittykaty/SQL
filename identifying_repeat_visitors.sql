-- identifying repeat visitors

-- identify user_ids and number of sessions

SELECT
	sessions AS repeat_session,
    COUNT(DISTINCT user_id) AS users
FROM(
SELECT
	user_id,
    SUM(is_repeat_session) AS sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
GROUP BY 1) AS number_of_sessions
GROUP BY 1
ORDER BY 1;
