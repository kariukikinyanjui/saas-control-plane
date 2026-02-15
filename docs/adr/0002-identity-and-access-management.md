# 2. Identity and Access Management Strategy

* **Status:** Accepted
* **Date:** 2026-02-15

## Context
A multi-tenant SaaS application requires a robust mechanism to:
1. Authenticate users securely.
2. Bind users to a specific tenant (preventing horizontal privilege escalation).
3. Authorize actions based on that tenant association.

I evaluated building a custom JWT solution versus using managed AWS services.

## Decision
I will separate **Authentication (Identity)** from **Authorization (Policy)** using two distinct managed services:
1. **Identity:** Amazon Cognito User Pools with a custom immutable attribute `tenant_id`.
2. **Authorization:** Amazon Verified Permissions using the Cedar policy language.

## Justification
* **Identity (Cognito):**
    * **Security:** Offloads the complexity of password hashing, MFA, and session management to AWS.
    * **Tenant Binding:** By using a custom attribute (`tenant_id`) that is **not writable** by the user, we cryptographically bind the user's identity to their data partition. This prevents "IDOR" attacks where a user simply changes a URL parameter to access another company's data.

* **Authorization (Verified Permission):**
    * **Decoupling:** Business logic (Python/Lambda) is separated from Security logic (Cedar). This allows security auditors to review permissions without reading application code.
    * **Granularity:** Cedar allows us to write attribute-based policies (ABAC) like `permit (principal, action, resource) when { principal.tenant_id == resource.tenant_id };`. This is significantly more robust than simple Role-Based Access Control (RBAC).

## Consequences
* **Positive:** "Bank-grade" security posture immediately upon deployment.
* **Positive:** Simplified compliance audits (just export the Cedar policies).
* **Negative:** Added latency. Every request requires a call the Verified Permissions engine (millisecond-level, but non-zero).
* **Negative:** Vendor Lock-in to AWS identity ecosystem.
