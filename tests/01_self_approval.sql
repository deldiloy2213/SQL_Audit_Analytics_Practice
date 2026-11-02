/*
Segregation of duties: payments where creator = approver. 
Rank employees by how many self-approvals they have.
*/
SELECT
	e.employee_id,
	e.name,
	COUNT(*) AS total_created,
	SUM(CASE WHEN p.created_by = p.approved_by THEN 1 ELSE 0 END) AS self_approved,
	ROUND (100.00 * SUM(CASE WHEN p.created_by = p.approved_by THEN 1 ELSE 0 END) / COUNT(*) , 2) AS percent_of_self_approved
FROM employees e
JOIN payments p
ON e.employee_id = p.created_by
GROUP BY 1,2
ORDER BY 4 DESC;