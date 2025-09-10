-- product refund rates

SELECT 
	YEAR(o.created_at) AS yr,
	MONTH(o.created_at) AS mo,
	SUM(CASE WHEN o.product_id=1 THEN 1 ELSE 0 END) AS p1_orders,
    SUM(CASE WHEN r.order_id IS NOT NULL AND o.product_id=1 THEN 1 ELSE 0 END)/SUM(CASE WHEN o.product_id=1 THEN 1 ELSE 0 END) AS p1_refund_rt,
    SUM(CASE WHEN o.product_id=2 THEN 1 ELSE 0 END) AS p2_orders,
    SUM(CASE WHEN r.order_id IS NOT NULL AND o.product_id=2 THEN 1 ELSE 0 END)/SUM(CASE WHEN o.product_id=2 THEN 1 ELSE 0 END) AS p2_refund_rt,
    SUM(CASE WHEN o.product_id=3 THEN 1 ELSE 0 END) AS p3_orders,
    SUM(CASE WHEN r.order_id IS NOT NULL AND o.product_id=3 THEN 1 ELSE 0 END)/SUM(CASE WHEN o.product_id=3 THEN 1 ELSE 0 END) AS p3_refund_rt,
    SUM(CASE WHEN o.product_id=4 THEN 1 ELSE 0 END) AS p4_orders,
    SUM(CASE WHEN r.order_id IS NOT NULL AND o.product_id=4 THEN 1 ELSE 0 END)/SUM(CASE WHEN o.product_id=4 THEN 1 ELSE 0 END) AS p4_refund_rt
FROM  order_items o
	LEFT JOIN order_item_refunds r
		ON o.order_id=r.order_id
WHERE o.created_at < '2014-10-15'
GROUP BY 1,2;