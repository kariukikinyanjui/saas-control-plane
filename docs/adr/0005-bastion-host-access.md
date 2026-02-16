# 5. Bastion Host for Private Database Access

* **Status:** Accepted
* **Date:** 2026-02016

## Context
The PostgreSQL database is deployed in a **Private Subnet** with no public IP address (as per ADR-0003).
* **Problem:** Developers and migration scripts need to run SQL commands against the database, but direct connection is impossible from the public internet.
* **Constraint:** I cannot compromise the "Hard Isolation" of the database by giving it a public IP.

## Decision
I provisioned a **Bastion Host** (Jump Server) in the Public Subnet.
* **Mechanism:** EC2 t2.micro instance running Amazon Linux 2023.
* **Access Method:** SSH Tunneling (Local Port Forwarding).
* **Security:**
    * Protected by a Security Group allowing ingress on Port 22.
    * Access requires a 4096-bit RSA Private Key (`bastion-key.pem`).

## Justification
* **Security vs. Usability:** The Bastion acts as a controlled "choke point." I monitor one single entry point (the Bastion) rather than exposing the database itself.
* **Cost:** The `t2.micro` is Free Tier eligible.
* **Simplicity:** SSH Tunneling is a standard industry practice supported by all major database tools (pgAdmin, DBeaver, Datagrip).

## Consequences
* **Positive:** The Database remains in the private subnet, unreachable by automated scanners/bots.
* **Negative:** Management overhead. I must securely manage the `bastion-key.pem`. If this key is lost, access is lost. If leaked, the Bastion is compromised.
* **Mitigation:** In a production environment, I would restrict the Bastion Security Group to the developer's specific IP address (not `0.0.0.0/0`) or replace SSH with **AWS Systems Manager (SSM) Session Manager** to eliminate open ports entirely.
