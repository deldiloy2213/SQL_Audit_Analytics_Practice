DROP TABLE IF EXISTS payments, vendors, employees CASCADE;

CREATE TABLE employees (
    employee_id   SERIAL PRIMARY KEY,
    name          TEXT NOT NULL,
    department    TEXT,
    hired_date    DATE,
    terminated_date DATE
);

CREATE TABLE vendors (
    vendor_id   SERIAL PRIMARY KEY,
    vendor_name TEXT NOT NULL
);

CREATE TABLE payments (
    payment_id   SERIAL PRIMARY KEY,
    vendor_id    INT REFERENCES vendors(vendor_id),
    amount       NUMERIC(12,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    created_by   INT REFERENCES employees(employee_id),
    approved_by  INT REFERENCES employees(employee_id)
);