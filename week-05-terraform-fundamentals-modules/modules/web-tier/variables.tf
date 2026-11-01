variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC to deploy into (from the vpc module)"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB and the ASG instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the launch template"
  type        = string
}

variable "asg_min" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_max" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
}

variable "asg_desired" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
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

variable "alert_email" {
  description = "Email address subscribed to the alarm topic. null means no subscription."
  type        = string
  default     = null
}
