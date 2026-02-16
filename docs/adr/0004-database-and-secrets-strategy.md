# 4. Database and Secrets Management Strategy

* **Status:** Accepted
* **Date:** 2026-02-16

## Context
The application requires a relational database to store tenant data.
* **Security Constraint:** Database credentials must never be hardcoded in the codebase or visible in plain text.
* **Operational Constraint:** I need automated backups, patching, and high availability without managing the OS.

## Decision
1. **Database Engine:** Amazon RDS for PostreSQL (db.t4g.micro).
2. **Credential Management:** AWS Secrets Manager with automatic rotation capability.
3. **Network Placement:** Private subnets only (No Public IP).
4. **Security:** Security Group allowing access only from the Application Layer.

## Justification
* **RDS vs. EC2:**
    * While running Postgres on an EC2 instance is cheaper (~$5/mo vs ~$12/mo for RDS), the operational overhead of managing OS patches, backups, and failover is too high for a solo developer, RDS offloads this "Undifferentiated Heavy Lifting."
    * The `db.t4g.micro` instance (ARM-based) offers the best price/performance ration for our current scale.

* **Secrets Manager vs. SSM Parameter Store:**
    * **Hardcoding Credentials** is a critical security vulnerability (CWE-798).
    * We use Terraform to generate a random 16-character password and immediately store it in Secrets Manager.
    * The application (Lambda) will retrieve these credentials at runtime via IAM authentication, ensuring that the "Secret" never exists on a developer's laptop or in Git history.
    * While SSM Parameter Store is cheaper, Secrets Manager provides native support for automatic credential rotation, which is a requirement for production systems.

## Consequences
* **Positive:** Zero credentials in git history.
* **Positive:** Automated daily backups and point-in-time recovery via RDS.
* **Negative:** Cost. Secrets Manager costs $0.40/secret/month + API calls. This is a worthwhile tradeoff for security.