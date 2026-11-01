variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "alert_email" {
  description = "Email address for CPU alarm notifications. Leave unset for no subscription."
  type        = string
  default     = null
}
