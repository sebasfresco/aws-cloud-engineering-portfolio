output "ecr_repository_url" {
  description = "ECR repository URL - use this for docker push"
  value       = module.ecr.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecr.repository_arn
}
