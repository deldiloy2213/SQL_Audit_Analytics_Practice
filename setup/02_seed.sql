TRUNCATE payments, vendors, employees RESTART IDENTITY CASCADE;

SELECT setseed(0.42);

INSERT INTO employees (name, department, hired_date)
SELECT 'Employee ' || g,
       (ARRAY['Finance','IT','Ops','HR'])[1 + floor(random()*4)::int],
       DATE '2020-01-01' + (random()*1500)::int
FROM generate_series(1, 50) g;

INSERT INTO vendors (vendor_name)
SELECT 'Vendor ' || g FROM generate_series(1, 30) g;

INSERT INTO payments (vendor_id, amount, payment_date, created_by, approved_by)
SELECT 1 + floor(random()*30)::int,
       round((random()*50000)::numeric, 2),
       TIMESTAMP '2026-01-01' + (random()*270) * INTERVAL '1 day',
       1 + floor(random()*50)::int,
       1 + floor(random()*50)::int
FROM generate_series(1, 5000);