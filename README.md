# Multi-Tenant SaaS Control Plane with Hard Data Isolation

## 1. The Business Problem
**Conflict:** A rapidly scaling B2B SaaS provider needs to onboard enterprise clients in regulated sectors (Finance & Healthcare).
* **The Constraint:** These clients mandate strict data isolation (no "cross-tenant spillage") and granualar audit logs.
* **The Problem:** The business cannot afford the operational overhead or cost of provisioning a dedicated database cluster for every single customer ("Instance-per-Tenant" model).


**The Solution:** An architecture that delivers the **compliance** of physical separation with the **economics** of shared infrastructure.

## 2. The Solution Architecture
Implemented a **Schema-per-Tenant** strategy on Amazon RDS (PostgreSQL).
* **Compute:** AWS Lambda (Serverless)
* **Database:** Amazon RDS (PostgreSQL)
* **Authorization:** Amazon Verified Permissions (Cedar Policy Engine)
* **Observability:** AWS X-Ray (PrivateLink)

## 3. Documentation
* [Architecture Decision Records (ARD)](docs/adr/)
* [System Design Diagram](docs/architecture/architecture.png)

