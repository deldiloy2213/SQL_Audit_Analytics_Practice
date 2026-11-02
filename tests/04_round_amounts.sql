/*
Round-number payments: amounts that are exact multiples of 500.
(No payments in this data are multiples of 1,000.)
*/
SELECT 
	*
FROM payments
WHERE MOD(amount, 500) = 0
ORDER BY vendor_id, created_by;