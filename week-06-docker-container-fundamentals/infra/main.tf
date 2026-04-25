terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source = "./modules/ecr"

  repository_name             = "${var.project_name}-flask-app"
  image_tag_mutability        = "IMMUTABLE"
  scan_on_push                = true
  max_untagged_image_age_days = 14

  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "terraform"
    Week        = "6"
  }
}
