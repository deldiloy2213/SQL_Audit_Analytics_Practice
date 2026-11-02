/*
Possible duplicates: the same vendor and same amount more than once. 
Extend it with payments within 7 days of each other using LAG.
*/
WITH gaps AS 
(
	SELECT 
		payment_id,
		vendor_id,
		amount,
		payment_date,
		LAG(payment_id)   OVER (PARTITION BY vendor_id, amount ORDER BY payment_date, payment_id) AS prev_payment_id,
		LAG(payment_date) OVER (PARTITION BY vendor_id, amount ORDER BY payment_date, payment_id) AS prev_date
	FROM payments
)
SELECT *, payment_date - prev_date AS gap
FROM gaps
WHERE payment_date - prev_date <= INTERVAL '7 days'
ORDER BY payment_id, vendor_id;