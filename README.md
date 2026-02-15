# Multi-Tenant SaaS Control Plane with Hard Data Isolation

## 1. The Business Problem
**Conflict:** A rapidly scaling B2B SaaS provider needs to onboard enterprise clients in regulated sectors (Finance & Healthcare).
* **The Constraint:** These clients mandate strict data isolation (no "cross-tenant spillage") and granualar audit logs.
* **The Problem:** The business cannot afford the operational overhead or cost of provisioning a dedicated database cluster for every single customer ("Instance-per-Tenant" model).


**The Solution:** An architecture that delivers the **compliance** of physical separation with the **economics** of shared infrastructure.

## 2. The Solution Architecture

### A. Identity & Access Management (The "Foundation")
* **Identity:** Amazon Cognito User Pools.
    * *Implementation:* Users are provisioned with a custom, immutable `tenant_id` attribute. This attribute is injected into the JWT ID Token, serving as the "Passport" for the session.
    * *Security:* Self-registration is disabled to prevent "Shadow IT".

* **Authorization:** Amazon Verified Permissions (AVP)
    * *Implentation:* We use the **Cedar** policy language to enforce "Zero Trust."
    * *Policy:* `permit (principal, action, resource) when { principal.tenant_id == resource.tenant_id };`
    * *Benefit:* Authorization logic is decoupled from application code, enabling independent security audits.

### B. Infrastructure & Governance
* **Infrastructure as Code:** 100% Terraform managed (`/infrastructure`).
* **FinOps:** automated AWS Budget alerts enforced via Terraform.
    * *Limit:* $25.00/month.
    * *Alerts:* 80% Actual Spend, 100% Forecasted Spend.

### C. Network Architecture (The Vault)
* **Design:** Custom VPC with strict Public/Private subnet separation.
* **Security:**
    * **Public Zone:** Contains the Application Load Balancer (ALB) and Bastion Host.
    * **Private Zone:** Houses the RDS Instance and Lambda Functions. **No Internet Gateway attachment.**

## 3. Documentation
* [ADR-0001: Data Isolation Strategy](docs/adr/0001-database-isolation-strategy.md)
* [ADR-0002: Identity and Access Management Strategy](docs/adr/0002-identity-and-access-management.md)
* [ADR-0003: Netowrk Isolation Strategy](docs/adr/0003-network-isolation-strategy.md)

---

* ![System Design Diagram](docs/architecture/architecture.png)

## 4. Project Roadmap & Status
| Phase                | Component                     | Tech Stack                  | Status           |
|----------------------|-------------------------------|-----------------------------|------------------|
| **1. Foundation**    | Identity, Authz, Governance   | Cognito, Cedar, AWS Budgets | ✅ **Completed** |
| **2. Networking**    | VPC, Subnets, Security Groups | AWS, VPC                    | ✅ **Completed** |
| **3. Data Plane**    | Database, Schema Isolation    | RDS PostgreSQL              | ⏳ *Pending*     |
| **4. Control Plane** | Request Routing               | API Gateway, Lambda         | ⏳ *Pending*     |
