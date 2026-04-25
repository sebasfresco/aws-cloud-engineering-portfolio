variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Tag mutability setting. IMMUTABLE prevents overwriting tags (recommended for prod)"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable vulnerability scanning when images are pushed"
  type        = bool
  default     = true
}

variable "max_untagged_image_age_days" {
  description = "Number of days to keep untagged images before automatic deletion"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}
