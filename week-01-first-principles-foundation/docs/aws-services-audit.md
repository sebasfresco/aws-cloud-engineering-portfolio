# AWS Services Audit

These are the AWS services I’ve used in production so far, with quick comparisons and the reason I chose each one.

The goal here isn’t to collect services. It’s to build judgment: what problem the service solves, what it costs, and what the trade-offs are.

---

## S3
Object storage for files, backups, and static content. Accessible over HTTP.

**Baseline cost:** ~$0.023/GB-month (S3 Standard)

### Comparisons
- **S3 vs EBS:**  
  EBS is block storage attached to EC2. S3 is object storage built for scale + durability.
- **S3 vs EFS:**  
  EFS is shared NFS storage for multiple EC2 instances. Great when you truly need concurrent mounts, but much more expensive.
- **S3 vs Glacier:**  
  Glacier is an S3 storage class. Cheap archival storage, slow retrieval.

### Why I chose it
Default storage layer. Mature, cheap, and everything integrates with it.

---

## Lambda
Runs code on-demand without managing servers. Great for event-driven workloads.

**Pricing model:** pay per request + execution time  
**Hard limit:** 15 minutes per invocation  
**State:** stateless by design

### Comparisons
- **Lambda vs EC2:**  
  EC2 is always-on compute. Lambda is pay-per-use compute.
- **Lambda vs Fargate:**  
  Fargate is for containers. Lambda is for functions.
- **Lambda vs Step Functions:**  
  Step Functions orchestrates. Lambda executes.

### Why I chose it
I had a short job triggered by file uploads. EC2 running 24/7 made no sense financially. Lambda was simpler and cheaper.

---

## EC2
Virtual servers with full control over OS, networking, and runtime. The most flexible compute option.

### Comparisons
- **EC2 vs Lambda:**  
  EC2 runs indefinitely and can hold state. Lambda is time-boxed and stateless.
- **EC2 vs Lightsail:**  
  Lightsail is simplified EC2 with fixed bundles. Good for basic sites, limited flexibility.
- **EC2 vs ECS/EKS:**  
  ECS/EKS are for container orchestration. EC2 is the straightforward option for traditional deployments.
- **EC2 vs Fargate:**  
  Fargate removes server management but trades off cost and control.

### Why I chose it
Simple web server + database workload. Predictable demand, low complexity, easy to troubleshoot.

---

## RDS
Managed relational databases (MySQL, PostgreSQL, SQL Server, Oracle, MariaDB). AWS handles backups, patching, and failover options.

### Comparisons
- **RDS vs DB on EC2:**  
  EC2 is full control but full responsibility. RDS costs more but removes operational burden.
- **RDS vs Aurora:**  
  Aurora is AWS-optimized and more scalable, but higher cost and a stronger “AWS lock-in” decision.
- **RDS vs DynamoDB:**  
  DynamoDB is NoSQL. RDS is relational SQL with joins and traditional schema design.

### Why I haven’t chosen it (yet)
My current database needs are small. RDS would add cost for features I don’t benefit from right now. I’ll move to RDS when HA/managed backups become worth the spend.

---

## IAM
Identity and access control for AWS. Users, roles, policies, API access.

### Comparisons
- **IAM vs AWS Identity Center (SSO):**  
  IAM is direct management. Identity Center is better for enterprise federated access.

### Why I chose it
You don’t really “choose” IAM. Everything depends on it.

---

## VPC
Private network boundary in AWS. Defines IP ranges, subnets, routing, and security boundaries.

### Key components
- **Subnets:** public vs private placement  
- **Route tables:** where traffic can go  
- **Security Groups:** stateful firewall rules per resource

### Comparisons
- **VPC vs default VPC:**  
  Default VPC is fine for testing. Custom VPC is what you want for production or anything with real constraints.

### Why I chose it
Mandatory for anything beyond simple experiments. It’s the base layer for security and network design in AWS.

---

## CloudWatch
Metrics, logs, alarms. The default observability layer in AWS.

**Notes**
- Basic metrics are included
- Custom metrics cost extra
- Alarms integrate easily with SNS and Auto Scaling

### Comparisons
- **CloudWatch vs Datadog/New Relic:**  
  Third-party tools often have better UI and correlation, but CloudWatch is already integrated and gets you 80% of what you need early.
- **CloudWatch vs EventBridge:**  
  CloudWatch is for metrics/logs. EventBridge is for event routing.

### Why I chose it
It’s already there and gets me alerts + visibility with minimal setup.

---

## Route 53
Domain registration and DNS hosting.

**Cost notes**
- ~$0.50/month per hosted zone
- queries are cheap at small scale

### Comparisons
- **Route 53 vs Cloudflare/registrar DNS:**  
  Route 53 wins when you’re deep in AWS because of alias records and easy integration with ALBs/CloudFront.

### Why I chose it
Everything staying inside AWS keeps it simple.

---

## SNS
Pub/sub notifications. Great for quick alerting.

### Common use
CloudWatch Alarm → SNS → email alert

### Comparisons
- **SNS vs SQS:**  
  SNS pushes to subscribers. SQS is a queue that consumers pull from.
- **SNS vs SES:**  
  SNS is for alerts. SES is for real email systems.

### Why I chose it
Fastest way to get alerts wired up, no overthinking.

---

## Billing & Cost Management
Cost Explorer, invoices, budgets, and billing alerts.

### Why I chose it
Not optional. Every AWS project is also a cost project.

---

## SES / WorkMail
- **SES:** transactional email sending API  
- **WorkMail:** hosted mailbox service

### Why I chose it
I wanted a domain email setup without paying for Google Workspace. WorkMail covers the mailbox, SES covers automated emails when needed.

---

## Bedrock
Managed LLM platform inside AWS. Access to models like Claude, Llama, Titan, and GPT (via AWS).

### Comparisons
- **Bedrock vs SageMaker:**  
  Bedrock is for consuming models. SageMaker is for training/hosting your own.
- **Bedrock vs external APIs:**  
  Keeps the workflow inside AWS and integrates well with the rest of the stack.

### Why I chose it
I built an agentic document-processing workflow and wanted a clean AWS-native approach for summarization and extraction.
