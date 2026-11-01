resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Enable basic image scanning on every push
  # Basic scanning checks OS packages only. Language packages (pip, npm)
  # need enhanced scanning through Amazon Inspector, which costs extra.
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
# Untagged images come from untagged pushes or buildx attestation manifests
# (the repo is IMMUTABLE, so a tag can never be overwritten)
# Tagged images are not expired by this rule
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
