# SQL Audit Analytics Practice

A self-directed project to practice testing payment controls with SQL. It uses a small PostgreSQL database of **synthetic** data (employees, vendors, payments) with a few anomalies planted deliberately, so the expected findings are known in advance.

It was built to practice control testing with SQL: joins, aggregations, subqueries, CTEs, and window functions. It does not contain any employer or real-world data.

## Data model

| Table | Key columns |
|---|---|
| `employees` | `employee_id`, `name`, `department`, `hired_date`, `terminated_date` |
| `vendors` | `vendor_id`, `vendor_name` |
| `payments` | `payment_id`, `vendor_id`, `amount`, `payment_date`, `created_by`, `approved_by` |

`payments.created_by` and `payments.approved_by` both reference `employees`. The data is 50 employees, 30 vendors, and 5,015 payments from January to late September 2026.

## How to run

Requires PostgreSQL and `psql`. From the repository root:

```bash
psql -U postgres -c "CREATE DATABASE audit_practice;"
psql -U postgres -d audit_practice -f setup/rebuild.sql
psql -U postgres -d audit_practice -f tests/05_exceptions_summary.sql
```

`rebuild.sql` drops and recreates the tables, loads the seeded random data, and plants the anomalies. Run it as one script so the random data is generated in a single session. Do not put passwords in any script.

## Planted anomalies

- **10 duplicate payments:** copies of payments 1 to 10, with new payment IDs but the same vendor, amount, and timestamp.
- **5 terminated employees** (IDs 3, 8, 15, 22, 41), all with a termination date of 2026-03-01.
- **5 payments of 9,500.00** created by those five employees on 2026-05-15 at 10:00, all approved by employee 1, just under an assumed 10,000 approval threshold.

The rest of the data is random. Some self-approvals and some activity after termination appear by chance, not by design.

## Tests

| File | Control objective | What it checks |
|---|---|---|
| `tests/01_self_approval.sql` | Creator and approver should be different people | Payments where `created_by = approved_by`, counted and rated per employee |
| `tests/02_after_termination.sql` | Only active employees create or approve payments | Payments created or approved after `terminated_date`, summarized per employee |
| `tests/03_duplicate_payments.sql` | One payment per obligation | Same vendor and amount within 7 days, using `LAG` |
| `tests/04_round_amounts.sql` | Amounts reflect real invoices | Amounts that are exact multiples of 500 |
| `tests/05_exceptions_summary.sql` | Work-paper summary | One row per test: exceptions, amount, and % of population |

## Results on this data

| Test | Exceptions | Amount | % of population |
|---|---|---|---|
| Self-approval | 103 | 2,535,249.15 | 2.05 |
| Created after termination | 386 | 9,900,796.14 | 7.70 |
| Approved after termination | 380 | 9636746.21 | 7.58 |
| Possible duplicates (excess rows) | 10 | 297305.31 | 0.20 |
| Round-number payments | 5 | 47,500.00 | 0.10 |

_Counts and amounts come from my own run. If you rebuild on a different PostgreSQL major version, random values can differ slightly._

## Why an exception might not be a problem

An exception is a lead, not a conclusion. Each test would need follow-up before anything is reported.

- **Self-approval:** a documented delegation, a coverage period, or a downstream review that acts as a compensating control.
- **After termination:** a wrong HR date, a rehire, a contractor conversion, or a shared or system account using the person's ID. Check access logs and HR history.
- **Duplicates:** recurring contract billing or a reversal pair. Identical timestamps with new IDs point to a double load, which should be confirmed with whoever owns the load.
- **Round amounts:** retainers, rent, and fixed fees are often legitimately round. The five flagged here are suspicious because of the combination (same amount, time, and approver, with terminated creators), not the roundness alone.

## Limitations

- The data is synthetic, so findings are known in advance and this is practice, not evidence of real audit work.
- There is no invoice or purchase-order number, so duplicates are matched on vendor, amount, and date only.
- The 10,000 approval threshold is an assumption, not a documented policy.
- The tests cover the full population. There is no sampling methodology.
- `terminated_date` is treated as authoritative. There is no rehire history.
- The data ends in late September, so the third quarter is partial.
