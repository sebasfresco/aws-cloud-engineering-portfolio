resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Enable image scanning on every push
  # Checks for CVEs in OS packages and language-level dependencies
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Encrypt images at rest with AWS-managed key
  # KMS CMK is available but adds cost with no real benefit for this use case
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = var.tags
}

# Lifecycle policy: automatically delete untagged images after N days
# Untagged images accumulate when you push new versions of the same tag
# Without this policy, ECR storage costs grow indefinitely
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after ${var.max_untagged_image_age_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.max_untagged_image_age_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
