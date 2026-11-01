# ------------------------------------------------------------------
# prod environment
# This directory is its own Terraform root, so it has its own state.
# Running terraform here can only change prod. The shared logic lives
# in ../../modules; the only thing this file adds is the prod values.
# ------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # State stays local (envs/prod/terraform.tfstate) for a solo lab.
  # For a team, move it to S3 with native locking (use_lockfile needs
  # Terraform 1.10 or later). Use a different key per
  # environment (or a different bucket and account for prod):
  #
  # backend "s3" {
  #   bucket       = "<your-state-bucket>"
  #   key          = "week5/prod/terraform.tfstate"
  #   region       = "us-east-1"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "week5"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = "week5-prod"
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
}

module "web_tier" {
  source = "../../modules/web-tier"

  project_name      = "week5-prod"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = "t3.medium"
  asg_min           = 2
  asg_max           = 6
  asg_desired       = 2
  alert_email       = var.alert_email
}
