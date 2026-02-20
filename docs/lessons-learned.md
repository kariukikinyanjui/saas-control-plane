# Architectural Challenges & Lessons Learned

As a Solutions Architect, encountering friction is part of the deployment process. Here are the key challenges faced during the construction of the SaaS Control Plane and how they were resolved.

### 1. The "Private Subnet / Secrets Manager" Paradox
* **Challenge:** The Lambda function, placed in a Private Subnet for security, time out after 10 seconds when trying to fetch the database password from AWS Secrets Manager via `boto3`.
* **Root Cause:** Private Subnets have no internet access. Secrets Manager is a public AWS API. The Lambda was indefinitely hanging trying to route out to the internet.
* **Resolution:** Instead of provisioning a costly NAT Gateway (~$32/mo) or a VPC Endpoint (~$7/mo), I shifted the credential retrieval to the infrastructure provisioning phase. Terraform fetches the secret at deployment and securely injects it as environment variables into the Lambda.

### 2. Immutable Infrastructure (Bastion Key Pairs)
* **Challenge:** Lost SSH access to the Bastion Host after deleting and recreating the local `.pem` key file.
* **Root Cause:** EC2 Key Pairs are baked into the instance at launch. You cannot simply swap a key file locally and expect the running server to accept it.
* **Resolution:** Leveraged Terraform's state management. By updating the `aws_key_pair` resource, Terraform correctly identified that the Bastion EC2 instace needed to be destroyed and recreated to apply the new hardware key, reinforcing the concept of immutable infrastructure.

### 3. Serverless Dependency Management (Lambda Layers)
* **Challenges:** Python Lambda functions failing with `AccessDeniedException` when trying to attach the `psycopg2` PostgreSQL driver.
* **Root Cause:** Attempted to use an outdated, deprecated Klayers ARN for Python 3.9.
* **Resolution:** Upgraded the Lambda runtime to Python 3.12 and mapped it to the modern, actively maintained public Lambda Layer ARN for `psycopg2-binary`.
