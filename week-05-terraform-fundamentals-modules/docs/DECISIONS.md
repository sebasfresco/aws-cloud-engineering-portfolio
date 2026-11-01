# Terraform Web Tier -- Decision Document

## Problem

Weeks 2 and 3 were built by clicking through the Console. That works once. It does not give me a record of what I changed, a way to review a change before it happens, or a way to rebuild the same thing in a second environment without repeating every click and hoping I get them all right.

The goal this week: describe the Week 3 web tier in Terraform, run a dev and a prod copy side by side, and be able to create or destroy either one with one command without touching the other.

## Proposed Architecture

- `modules/vpc`: VPC, internet gateway, 2 public and 2 private subnets across 2 AZs, public route table. No NAT gateway.
- `modules/web-tier`: ALB and web security groups, ALB, target group, listener, launch template (Amazon Linux 2023, IMDSv2 required), Auto Scaling Group, target tracking policy, SNS topic and CPU alarm.
- `envs/dev` and `envs/prod`: one Terraform root each. They call both modules with their own values and keep their own state.

## Design Decisions

### 1. Environment separation: one directory per environment, not workspaces

**Decision:** `envs/dev` and `envs/prod` are separate root configurations. Each has its own state file. The shared logic lives in the modules.

**Alternatives considered:**
- **One root and two tfvars files** (what I had first). Both environments shared one state file, so `terraform apply -var-file=prod.tfvars` did not create prod next to dev. It planned to change the dev resources into prod ones. That was my first layout, and the README wrongly said both could coexist.
- **CLI workspaces** (`terraform workspace new prod`). Each workspace gets its own state, so this fixes the bug above. But all workspaces in a directory share one backend, so they share the same bucket and the same credentials. The environment you are about to change is hidden state (whichever workspace is selected), not something visible in the path or in a pull request.

**Why:** HashiCorp's own workspace docs say CLI workspaces use the same backend and are "not a suitable isolation mechanism" when you want strong separation between stages like dev and prod. They recommend a reusable module plus a separate configuration per deployment, which is this layout. With directories, the environment is the folder I am standing in. Prod can later move to its own bucket, or its own account, by changing one backend block.

**Trade-off:** each environment has about 60 lines of root code that look alike. That is the price of the separation. The real logic is still written once in the modules.

**When workspaces are the right call:** short-lived copies of the same environment that share credentials, such as a throwaway stack per feature branch.

### 2. State: local for now, S3 with native locking when shared

**Decision:** each environment keeps local state (`envs/<env>/terraform.tfstate`, gitignored). Each `main.tf` has a commented S3 backend block with a different key per environment.

**Why:** this is a solo lab that gets torn down when not in use. Remote state would add a bucket I have to bootstrap before the first apply. For a team, local state is not an option: it cannot be shared or locked.

**Note:** the S3 backend now locks with `use_lockfile = true`. DynamoDB-based locking is deprecated, so a new setup should not add a DynamoDB table for this.

### 3. Modules: one for networking, one for the web tier

**Decision:** two modules, `vpc` and `web-tier`. Security groups live inside `web-tier`.

**Why:** three environments with identical VPCs would be 300+ lines of duplicated code. Change one thing and you have to change it in 3 places. Modules let you change it once.

I had a separate security group module in an earlier version and removed it. At two security groups it added indirection without payoff, and it could not express source-SG references, which is why the web SG ended up open to `0.0.0.0/0`.

**What modules do not do:** they do not stop drift. Someone can still change a resource in the Console. `terraform plan` is what detects that (decision 7).

### 4. Health checks: ELB, not EC2

**Decision:** `health_check_type = "ELB"` with a 300 second grace period.

**Why:** EC2 health checks only verify that the instance is running at the hypervisor level. ELB health checks send HTTP requests to confirm the application is actually responding. An instance can be "running" while the web server process has crashed. ELB checks catch that, EC2 checks do not.

### 5. Security groups: separate ALB and web SGs

**Decision:** the ALB SG allows HTTP from anywhere. The web SG allows HTTP only from the ALB SG, using a security group reference rather than a CIDR. No SSH.

**Why:** separation enforces least privilege. A shared security group would expose instances directly to the internet. It is also defense in depth: if the ALB is misconfigured, there is still a second layer of access control at the instance level. My first version got this wrong (the web SG was open to the internet), which I fixed in a later commit.

### 6. Scaling: target tracking, plus a separate alarm for humans

**Decision:** a target tracking policy holds average CPU at 60%. A separate CloudWatch alarm at 80% for 10 minutes notifies an SNS topic.

**How they relate:** they are independent. With target tracking, EC2 Auto Scaling creates and manages its own CloudWatch alarms to scale in and out, and AWS says not to edit or delete them. My 80% alarm does not trigger scaling. It only tells a human that CPU is still high, which matters when the ASG has already hit `max_size` and cannot add more.

**Why 60%:** traffic is spiky. At 80%, a spike hits 100% before a new instance finishes launching (2-3 minutes). 60% leaves a buffer. The trade-off is slightly higher cost from extra capacity.

**Alternative:** step scaling, where I would write the alarm and the policy myself and the alarm would invoke the policy. More control, more to get wrong. Target tracking is the better default.

### 7. Drift: detect with plan, decide before apply

**Decision:** treat `terraform plan` as the drift check. Any manual Console change is either copied into code or reverted on purpose.

**Why:** drift is when reality no longer matches your Terraform configuration. Someone changes a security group manually during an incident. The next `terraform plan` shows that change being reverted, and if nobody reads the plan, `terraform apply` reverts it. That is not silent, but it is easy to miss. Over time, unmanaged drift is how "snowflake" infrastructure happens: environments that collected undocumented changes and can never be cleanly reproduced.

### 8. VPC CIDRs: different ranges for dev and prod

**Decision:** dev uses `10.0.0.0/16`, prod uses `10.1.0.0/16`.

**Why:** if dev and prod share the same CIDR, you can never peer them or connect them to a shared services VPC, because the routes would be ambiguous. Non-overlapping ranges also let you write rules that explicitly allow or deny cross-environment traffic, and a source IP alone tells you which environment it came from.

## Terraform Concepts Behind These Decisions

**Why does Terraform keep a state file instead of just reading AWS?** AWS does not know which resources "belong" to your Terraform project. If you have 100 VPCs in your account, Terraform needs to know which one it created. The state file is the mapping between your code and reality.

**Plan vs apply.** Plan is read-only. It refreshes what exists, compares it to the code, and shows a diff. Apply executes that diff. In production, a teammate reviews the plan before anyone runs apply. This is the infrastructure version of a code review.

**Why file order does not matter.** Terraform builds a dependency graph from references. When a subnet says `vpc_id = aws_vpc.this.id`, Terraform knows the VPC must exist first.

**`aws_vpc.this.id` vs `module.vpc.vpc_id`.** The first reads a resource attribute directly. The second reads a module output. You cannot reach into a module and read `module.vpc.aws_vpc.this.id`. You can only use what the module exports. This is encapsulation.

**What forces a replacement?** It depends on the resource. Changing tags is an in-place update. On a standalone `aws_instance`, changing `instance_type` is also in place: the provider stops the instance, changes the type and starts it again, so expect downtime, not a new instance. In this repo the instance type lives in a launch template, so changing it creates a new template version and nothing else. Running instances keep the old type until they are replaced, for example by an instance refresh. `terraform plan` tells you which case you are in: look for "must be replaced".

**Why `-target` is for emergencies.** `-target` does not bypass the dependency graph. Terraform still includes what the target depends on, and `destroy -target` also destroys what depends on the target. The danger is that you apply part of a configuration. The rest of the plan is never shown, state and code drift apart, and the next full plan contains surprises. HashiCorp describes it as a tool for recovering from mistakes, not routine use. If I need it regularly, the configuration should be split.

## Cost

Dev runs about $35/month plus LCU charges while it is up: ALB about $16.43, one t3.micro about $7.59, and three public IPv4 addresses (two on the ALB, one on the instance) about $10.95. See the [README](../README.md#cost-reality-us-east-1-dev) for the table.

A cost-conscious production version starts from this and hardens it: two AZs, the ALB in public subnets, the ASG in private subnets (which removes the per-instance public IPv4 charge but needs a NAT gateway or VPC endpoints for updates), and instance types chosen from CloudWatch data rather than guesses. Spot for stateless capacity, and Savings Plans once the baseline is predictable.

## Business Case

IaC is a risk, speed and cost decision, not a technical preference. Every change goes through a pull request with a `terraform plan` diff before it touches production, which removes the "one wrong checkbox" problem of Console management. A new environment is a new directory that calls the same modules, which takes minutes instead of days. Every infrastructure change is a git commit with an author, a timestamp and a reason, so when an auditor asks "who opened port 22?", the answer exists. Cost decisions like instance types and ASG sizing are explicit in code, and drift (someone manually upsizing an instance and forgetting) shows up on the next plan. If the account is compromised or a region fails, the infrastructure is rebuilt from code in hours, not weeks.

## What Breaks If You Change It

| Change | What breaks |
| --- | --- |
| Go back to one root with two tfvars files | Applying prod changes dev. Both share one state file. |
| Use the same CIDR in dev and prod | No peering or shared services VPC later. Routes are ambiguous. |
| Fixed `name` on the ASG instead of `name_prefix` | Any change that forces a replacement fails, because `create_before_destroy` needs two ASGs with different names. |
| `health_check_type = "EC2"` | Instances with a crashed httpd stay in service and return errors. |
| Web SG allows `0.0.0.0/0` | Instances are reachable directly on their public IPs, skipping the ALB. |
| Delete the SNS email subscription | The alarm still fires, but nobody hears about it. |
| Edit the target tracking alarms by hand | Auto Scaling can overwrite or replace them, and scaling becomes unpredictable. |
| Stop committing `.terraform.lock.hcl` | Two people can run different provider versions against the same state. |
