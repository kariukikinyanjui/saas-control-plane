# 6. Data Isolation Strategy (Schema-per-Tenant)

* **Status:** Accepted
* **Date:** 2026-02016

## Context
A multi-tenant SaaS application needs to store data for multiple customers (Tenants).
* **Isolation Requirement:** Tenant A must **never** see Tenant B's data.
* **Cost Requirement:** I cannot afford a separate RDS instance for every tenant ($15/mo * 100 tenants = $1500/mo).

I evaluated three models:
1. **Silo (Instance-per-Tenant):** Highst security, highest cost.
2. **Pool (Row-Level Security):** Lowest cost, lowest security (easy to miss a `WHERE` clause).
3. **Bridge (Schema-per-Tenant):** Shared instance, but separate PostgreSQL Schemas.

## Decision
I selected the **Bridge Model (Schema-per-Tenant)**.

## Justification
* **Security:** A logical "Firewall" exists between tenants. Even if the application code fails to filter by ID, the database user (in the future) can be restricted to a specific schema.
* **Performance:** Keeping tables small (per-tenant) often performs better than one massive table with millions of mixed rows.
* **Tooling:** Backup and Restore can be done per-schema (e.g, "Restore just Tenant A")

## Consequences
* **Positive:** Strong data isolation without the cost of separate instances.
* **Positive:** Simplified "GDPR" compliance  (easier to delete one tenant's data completely).
* **Negative:** Migration complexity. We must run migration scripts N times for N tenants.
* **Negative:** Connection Pooling. Each tenant might require separate connections, potentially exhausting the database connection limit. We will mitigate this with **RDS Proxy** if we scale beyond 50 tenants.

