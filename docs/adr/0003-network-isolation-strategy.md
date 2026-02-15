# 3. Network Isolation Strategy

* **Status:** Accepted
* **Date:** 2026-02-15

# Context
The application requires a secure environment for the database (RDS) and compute (Lambda).
* **Security Constraint:** The database must never be accessible from the public internet.
* **Budget Constraint:** The project has a strict hard limit of $25/month.

I evaluated using the Default VPC vs. a Custom VPC, and standard NAT Gateway vs. alternative connectivity options.

## Decision
I implemented a **Custom VPC with Strict Public/Private Isolation** and **Excluded the NAT Gateway**.

## Justification
1. **Custom VPC (Selected):**
    * The Default VPC creates public subnets by default. To adhere to "Secure by Design" principles, I created a blank slate where explicit action is required to expose a resource.
    * I defined two distinct zones:
        * **Public Zone:** Attached to an Internet Gateway (IGW). Intended for Load Balancers or Bastion Hosts.
        * **Private Zone:** No route to the internet. Intended for RDS and Lambda

2. **No NAT Gateway (Selected):**
    * A standard AWS NAT Gateway costs ~0.045/hour + data processing, totalling approx. **$32/month**.
    * This single resource would exceed the entire project budget ($25/mo).
    * *Alternative:* Since our Lambda mainly needs to talk to AWS Services (Dynao, S3, X-Ray), I will use **VPC Endpoints** (PrivateLink) which are cheaper and more secure, or a temporary "NAT Instance" (EC2 t4g.nano) if external internet access is strictly required.

## Consequences
* **Positive:** The database is physically isolated from the internet (Attach Surface Reduction).
* **Positive:** Massive cost avoidance ($300+/year saved by skipping NAT Gateway).
* **Networking:** Resources in the private subnet cannot download updates or reach 3rd-party APIs (e.g., Stripe) without additional configuration. I will addreess this via VPC Endpoints as needed.
