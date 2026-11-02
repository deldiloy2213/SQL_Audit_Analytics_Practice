/*
Exception Summary: test name, number of exceptions, total exception amount, and % of population.
*/
-- Query for Self-approvals
SELECT 
	'Self-approval' AS test,
	COUNT(*) AS exceptions,
	SUM(amount) AS exception_amount,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM payments), 2) AS pct_of_population
FROM payments
WHERE created_by = approved_by
UNION ALL
-- Query for Payments created after termination
SELECT 
	'Created after termination',
	COUNT(*), SUM(p.amount),
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM payments), 2)
FROM payments p
JOIN employees e ON e.employee_id = p.created_by
WHERE p.payment_date > e.terminated_date
UNION ALL
-- Query for Payments approved after termination
SELECT 
	'Approved after termination',
	COUNT(*), SUM(p.amount),
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM payments), 2)
FROM payments p
JOIN employees e ON e.employee_id = p.approved_by
WHERE p.payment_date > e.terminated_date
UNION ALL
-- Query for Possible duplicate payments
SELECT 
	'Possible duplicates',
	SUM(n - 1),
	SUM((n - 1) * amount),
	ROUND(100.0 * SUM(n - 1) / (SELECT COUNT(*) FROM payments), 2)
FROM (
  SELECT vendor_id, amount, payment_date, COUNT(*) AS n
  FROM payments
  GROUP BY vendor_id, amount, payment_date
  HAVING COUNT(*) > 1
 ) AS d
UNION ALL
-- Query for round-number of payments
SELECT 
	'Round-number Payments',
	COUNT(*),
	SUM(amount),
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM payments), 2)
FROM payments
WHERE MOD(amount, 500) = 0;