# 1. Database Isolation Strategy: Schema-per-Tenant

* **Status:** Accepted
* **Date:** 2026-02-14


## Context
The business requires a multi-tenant architecture that supports strict data isolation for enterprise clients in regulated industries (Finance, Healthcare).
Evaluated three core isolation models:
1. **Instance-per-Tenant:** A dedicated RDS instance for every client.
2. **Pool Model:** Shared tables with a `tenant_id` column (Row-Level Security).
3. **Schema-per-Tenant:** Shared RDS instance, but unique PostgreSQL schemas for each client.


## Decision
Implement the **Schema-per-Tenant** model using PostgreSQL on Amazon RDS.

## Justification
* **Rejected Instance-per-Tenant:** While this offers the highest isolation, the cost grows linearly with customer count. Managing hundreds of RDS instances is operationally unviable for our current team size.
* **Rejected Pool Model:** While cheapest, "soft" isolation (WHERE clauses) is often insufficient for strict compliance audits. A coding error could expose Competitor A's data to Competitor B.
* **Selected Schema-per-Tenant:** This provides **Logical Hard Isolation**.
    * Data is separated at the database engine level (different namespaces).
    * We can secure it effectively using the `SET search_path` command at the start of every transaction.
    * It allows us to run hundreds of tenants on a single `db.t4g.small` instance, keeping costs flat.

## Consequences
* **Positive:** Massive cost savings compared to dedicated instances.
* **Positive:** Simplified compliance; we can grant specific database users access only to specific schemasl
* **Negative:** Database migrations are more complex. We must iterate through every schema to apply updates.
* **Negative:** "Noisy Neighbour" risk. One heavy tenant could slow down the entire instance. We will mitigate this with aggressive connection timeouts and eventual rate limiting.
