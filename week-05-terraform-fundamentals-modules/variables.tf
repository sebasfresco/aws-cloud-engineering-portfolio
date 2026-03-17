variable "instance_type" {
  description = "EC2 instance type. t2.micro for dev (free tier), t3.medium for prod."
  type        = string
  default     = "t2.micro"
}

variable "asg_min" {
  description = "Minimum number of instance in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max" {
  description = "Maximum number of instance in the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired" {
  description = "Desired number of instance in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources (used in tags)"
  type        = string
  default     = "week5"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "app_port" {
  description = "Port the web application listens on (used by ALB, target group, and security groups)"
  type        = number
  default     = 80
}

variable "cpu_target_value" {
  description = "Target average CPU utilization (%) for the ASG scaling policy"
  type        = number
  default     = 60.0
}

variable "alarm_cpu_threshold" {
  description = "CPU utilization (%) that triggers the CloudWatch alarm to notify humans"
  type        = number
  default     = 80
}
