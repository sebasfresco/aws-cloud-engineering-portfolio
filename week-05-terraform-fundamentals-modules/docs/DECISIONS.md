What problem does Terraform solve that the AWS Console does not?
Think about reproducibility, auditability, collaboration, speed of deployment, human error, and the ability to review changes before they happen.

Why does Terraform use a state file instead of just reading what exists in AWS?
AWS does not know which resources "belong" to your Terraform project. If you have 100 VPCs in your account, Terraform needs to know which one it created so it can manage it. The state file is the mapping between your code and reality.

What is the difference between terraform plan and terraform apply?
Plan is read-only. It compares code to state to reality and shows a diff. Apply executes that diff. In production, the plan would be reviewed by a teammate before anyone runs apply. This is the infrastructure equivalent of a code review.

Why does the order of resources in main.tf not matter?
Terraform builds a dependency graph from references. When the subnet says vpc_id = aws_vpc.main.id, Terraform knows the VPC must exist first. You could put the subnet at the top and the VPC at the bottom and it would still work.

Why does changing a tag NOT require instance replacement, but changing instance_type MIGHT?
Tags are metadata in the AWS control plane, updated via API call. Instance type is tied to physical hardware. AWS must stop, migrate, and restart.

Why is terraform destroy -target useful for learning but dangerous in production?
Targeted destroy bypasses the dependency graph. In production, always use full terraform plan/terraform apply.

Why modularize Terraform code?
3 environments with identical VPCs = 300+ lines of duplicated code. Change one thing = change in 3 places. Modules let you change once.

What is the difference between aws_vpc.main.id and module.vpc.vpc_id?
The first directly accesses a resource attribute. The second accesses a module output. Modules hide their internals. You cannot reach into a module and access module.vpc.aws_vpc.this.id. You can only use what the module explicitly exports via outputs. This is encapsulation.

What is drift and why does it matter?
Drift is when reality no longer matches your Terraform state. Someone changes a security group manually during an incident and now your state file says one thing, AWS says another. The danger is that the next terraform apply silently reverts that manual change. Over time, drift is how "snowflake" infrastructure happens: environments that accumulated undocumented changes and can never be cleanly reproduced.

Why use different CIDRs for dev and prod?
If dev and prod share the same CIDR (both 10.0.0.0/16), you can never peer them or connect them to a shared services VPC because the routes would be ambiguous. Non-overlapping ranges also let you write security group rules that explicitly allow or deny cross-environment traffic, and a source IP alone tells you which environment it came from.

Why health_check_type = "ELB" instead of default "EC2"?
EC2 health checks only verify that the instance is running at the hypervisor level. ELB health checks go further by sending HTTP requests to confirm the application is actually responding. An instance can be "running" while the web server process has crashed. ELB checks catch that, EC2 checks do not.

Why separate ALB and web instance security groups?
Separation enforces the principle of least privilege. The ALB security group allows public internet traffic on port 80/443, while the web instance security group only accepts traffic from the ALB. A shared security group would expose instances directly to the internet. This is also defense in depth: if the ALB is compromised, the attacker still faces a second layer of access control at the instance level.

Why have both a scaling policy AND a CloudWatch alarm?
They serve different roles. The scaling policy defines what to do, i.e. add or remove instances and by how much. The CloudWatch alarm defines when to do it, i.e. it watches a metric like CPU utilization and fires when it crosses a threshold. Neither works alone. A policy with no alarm never triggers, and an alarm with no policy has nothing to execute. Together they form a feedback loop. CloudWatch detects that CPU has exceeded 80%, triggers the alarm, which invokes the scaling policy, which adds capacity, which brings CPU back down, which resolves the alarm.

What would a cost-conscious production deployment look like?
Start with the dev architecture and harden it. At minimum: a VPC spanning two AZs for high availability, each with a public and private subnet. An ALB in the public subnets distributes traffic to an ASG in the private subnets. The launch template defines the instance type based on your workload: general-purpose (t3/t3a) for most web apps, compute-optimized (c-series) for CPU-bound work. To cut costs further: use Spot Instances for stateless workloads, right-size instances based on actual CloudWatch metrics rather than guessing, and set ASG min/max/desired carefully so you are not over-provisioning during low-traffic periods. Reserved Instances or Savings Plans reduce the bill once your baseline is predictable.

What is the business case for IaC?
IaC is a risk, speed, and cost decision, not a technical preference. Every change goes through a pull request with a terraform plan diff before touching production, eliminating the "one wrong checkbox" problem of Console management. New environments are a single command with a new .tfvars file, taking minutes instead of days. Every infrastructure change is a git commit with an author, timestamp, and reason, so when an auditor asks "who opened port 22?", the answer exists. Cost decisions like instance types and ASG sizing are explicit in code, and drift (someone manually upsizing an instance and forgetting) is caught on the next plan. If the account is compromised or a region fails, the infrastructure is rebuilt from code in hours, not weeks. A new engineer reads main.tf and understands the architecture on day one instead of learning tribal Console knowledge. The net effect: fewer outages, faster delivery, lower bills, clean audits, and a team that scales.
