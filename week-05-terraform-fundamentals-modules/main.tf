# ------------------------------------------------------------------
# Terraform configuration block
# Specifies which providers we need and minimum Terraform version.
# The AWS provider is the plugin that knows how to create AWS resources.
# "~> 5.0" means "any version 5.x" (allows minor updates, not major).
# ------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

# ------------------------------------------------------------------
# Provider block
# Tells Terraform to use AWS and specifies the region.
# The region comes from a variable so we can change it without
# editing this file.
# ------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------
# VPC Module
# All networking is encapsulated in modules/vpc. The root config
# passes parameters for this environment.
# ------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  name                 = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ALB security group: HTTP from the internet.
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "ALB security group - HTTP from internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Web instance SG: only accepts traffic from the ALB. Direct hits from the
# internet to instance public IPs are blocked at the SG level. SSH is
# intentionally absent — user_data does the setup; use SSM Session Manager
# if you need ops access.
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Web instance SG - traffic only from ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# ------------------------------------------------------------------
# Data source: Latest Amazon Linux 2023 AMI
# AMI IDs differ per region and get updated regularly. Hardcoding
# an AMI ID breaks when you change regions or AWS publishes a new
# image. This data source always fetches the latest.
# ------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ------------------------------------------------------------------
# Application Load Balancer
# Gives load balancing capabilities to our EC2 instances.
# Health checks included.
# ------------------------------------------------------------------
resource "aws_lb" "web" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Health checks hit the root page every 30s. Must pass 2 checks
# to be healthy. Must fail 3 to be unhealthy. Only 200 counts.
resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# ------------------------------------------------------------------
# ALB Listener
# Connects the ALB to the target group. Without a listener, the ALB
# accepts connections but has no rules to route them, so traffic is dropped.
# ------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# ------------------------------------------------------------------
# Launch Template
# Defines what each ASG instance looks like. user_data must be
# base64-encoded in launch templates (unlike plain aws_instance).
# ------------------------------------------------------------------
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id)
    echo "<h1>Terraform Week 5</h1><p>Instance: $INSTANCE_ID</p>" > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-asg-instance"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------
# Auto Scaling Group
# health_check_type = "ELB" checks if the app responds to HTTP,
# not just if the VM is running. An instance with crashed httpd
# gets replaced. health_check_grace_period gives instances 5 min
# to boot before checking starts.
# ------------------------------------------------------------------
resource "aws_autoscaling_group" "web" {
  name                      = "${var.project_name}-asg"
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  min_size                  = var.asg_min
  vpc_zone_identifier       = module.vpc.public_subnet_ids
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------
# Scaling policy
# Keeps average CPU at ~60%. Why not 80%? Traffic is spiky. At 80%,
# a spike hits 100% before new instance launch (2-3 min). 60%
# leaves a buffer. Tradeoff: slightly higher cost from extra capacity.
# ------------------------------------------------------------------
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project_name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_value
  }
}

# ------------------------------------------------------------------
# SNS Topic
# Decouples alert delivery from alarm definition. Subscribers (email, Slack,
# PagerDuty) can be added without touching the alarm resource.
# ------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

# Notification layer separate from auto-scaling. Scaling policy
# handles remediation (adding instances). This alarm handles
# alerting humans. You need both because scaling can hit max
# capacity and humans need to know.
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.alarm_cpu_threshold
  alarm_description   = "CPU exceeds ${var.alarm_cpu_threshold}% for 10 minutes"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}
