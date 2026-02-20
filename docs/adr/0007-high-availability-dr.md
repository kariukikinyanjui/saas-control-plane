# 8. High Availability (HA) and Disaster Recovery (DR) Strategy

* **Status:** Accepted
* **Date:** 2026-02-20

## Context
The SaaS Control Plane hosts sensitive multi-tenant data for regulated industries. In a production scenario, strict SLAs (Service Level Agreements) require the system to withstand Availability Zone (AZ) failures and regional outages. However, for the current Proof of Concept (PoC) phase, we operate under a strict FinOps budget constraint (~$25/month).

We need to define the HA/DR architecture for production while justifying the scaled-down implementation used in the PoC.

## Decision
1. **For the PoC:** We accept the risk of a Single-AZ database deployment to strictly control costs.
2. **For Production:** We define a Multi-AZ and Cross-Region strategy utilizing native AWS managed services to meet enterprise Recovery Point Objective (RPO) and Recovery Time Objective (RTO) targets.

## Jusitification & Architecture

### 1. Compute & Identity (Natively HA)
Both the PoC and Production environments utilize **Amazon API Gateway**, **AWS Lambda**, and **Amazon Cognito**.
* **Why:** These serverless services are natively highly available. AWS automatically distributes them across multiple Availability Zones within a region. If one AZ goes down, compute traffic is seamlessly routed to another with zero manual intervention or additional cost.

### 2. Network (Foundationally HA)
The VPC is provisioned via Terraform with Public and Private subnets spanning two Availability Zones(`us-east-1a` and `us-east-1b`).
* **PoC State:** The foundation is ready, but active HA routing (like NAT Gateways in each AZ) is omitted to save ~$64/month.
* **Production State:** Deploy redundant NAT Gateways in each Public Subnet to ensure Lambda functions in any AZ can reach external APIs without a single point of failure.

### 3. Data Plane: High Availability (Intra-Region)
* **PoC State:** Amazon RDS PostgreSQL is deployed in a Single-AZ configuration (`db.t3.micro`).
* **Production State:** Enable **RDS Multi-AZ**. This provisions a synchronous standby replica in a different AZ. In the event of an infrastructure failure, Amazon Route 53 automatically updates the database DNS endpoint to point to the standby, achieving an RTO of typically 60-120 seconds with zero data loss (RPO = 0).

### 4. Data Plane: Disaster Recovery (Cross-Region)
* **Production State:** To survive a complete regional outage (e.g., all of `us-east-1` goes down):
    * Enable **Automated Backups** with a 30-day retentioni period.
    * Enable **Cross-Region Snapshot Copy** to a fallback region (e.g., `us-wesst-2`).
    * For Tier-1 enterprise tenants requiring extreme RTO/RPO, implement **RDS Cross-Region Read Replicas** for asynchronous replication, which can be promoted to a standalone primary
    database if the primary region fails.

## Consequences
* **Positive:** The PoC remains extremely cost-effective while stiill utilizing a network topology capable of suporting enterprise HA.
* **Positive:** Clear, documented upgrade path for when the platform scales to paying customers.
* **Negative (PoC Risk):** If the specific underlying hardware hosting the Single-AZ RDS instance fails, the PoC API will experience downtime until AWS recovers the instance.
