/*
Terminated users: payments created or approved after the employee’s terminated_date. 
*/
SELECT
	'creator' AS role,
	e.employee_id,
	e.name,
	COUNT(*) AS n,
	SUM(amount) AS payment,
	e.terminated_date
FROM employees e
JOIN payments p
ON e.employee_id = p.created_by
WHERE e.terminated_date IS NOT NULL AND p.payment_date > e.terminated_date
GROUP BY 1, 2, 3, 6
UNION ALL
SELECT
	'approver' AS role,
	e.employee_id,
	e.name,
	COUNT(*) AS n,
	SUM(amount) AS payment,
	e.terminated_date
FROM employees e
JOIN payments p
ON e.employee_id = p.approved_by
WHERE e.terminated_date IS NOT NULL AND p.payment_date > e.terminated_date
GROUP BY 1, 2, 3, 6
ORDER BY 1, 2;