# 6. Serverless Application Logic (Tenant Context)

* **Status:** Accepted
* **Date:** 2026-02-17

## Context
The application needs to serve data to users from their specific tenant schema.
* **Requirement:** The API must identify the tenant from the request and restrict database queries to that tenant's schema.
* **Constraint:** We want to avoid "Hardcoding" tenant IDs in SQL queries (e.g., `SELECT * FROM tenant_a.todos`), as this is brittle and prone to injection attacks.

## Decision
I implemented a **Serverless Lambda with Runtime Schema Switching**.

## Justification
1. **Runtime Switching:**
    * Instead of dynamic SQL, we use the PostgreSQL `SET search_path TO "tenant_id"` command at the start of every session.
    * This allows us to write generic SQL (`SELECT * FROM todos`) without worrying about which tenant is active.
The database engine handles the isolation.

2. **Serverless (Lambda):**
    * **Cost:** I only pay for the milliseconds the code runs. For a portfolio project with low traffic, this is effectively free.
    * **Scale:** Lambda automatically scales from 0 to 1,000 concurrent requests without us managing servers.

3. **Language (Python + Psycopg2):**
    * Python offers the best balance of speed and readability for backend logic.
    * I use a **Lambda Layer** to manage the binary dependencies (`psycopg2`), keeping out deployment package small.

## Consequences
* **Positive:** "Write Once, Run for Any Tenant" code simplicity.
* **Positive:** Strong security guarantee (the session is locked to the schema).
* **Negative:** Cold Starts. The first request after a period of inactivity may take 1-2 seconds while the Lambda initializes and connects to the DB.
