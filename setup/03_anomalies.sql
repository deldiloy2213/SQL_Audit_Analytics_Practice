-- 1) 10 duplicate payments planted (copies of payment_id 1-10)
INSERT INTO payments (vendor_id, amount, payment_date, created_by, approved_by)
SELECT vendor_id, amount, payment_date, created_by, approved_by
FROM payments
ORDER BY payment_id
LIMIT 10;

-- 2) 5 employees terminated on 2026-03-01
UPDATE employees
SET terminated_date = DATE '2026-03-01'
WHERE employee_id IN (3, 8, 15, 22, 41);

-- 3) 5 payments created by those employees AFTER termination,
--    each 9,500.00 (just under a 10,000 approval threshold)
INSERT INTO payments (vendor_id, amount, payment_date, created_by, approved_by)
SELECT 1 + floor(random()*30)::int,
       9500.00,
       TIMESTAMP '2026-05-15 10:00',
       e,
       1
FROM unnest(ARRAY[3, 8, 15, 22, 41]) AS e;