# ------------------------------------------------------------------
# dev environment
# This directory is its own Terraform root, so it has its own state.
# Running terraform here can only change dev. The shared logic lives
# in ../../modules; the only thing this file adds is the dev values.
# ------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # State stays local (envs/dev/terraform.tfstate) for a solo lab.
  # For a team, move it to S3 with native locking (use_lockfile needs
  # Terraform 1.10 or later). Use a different key per
  # environment (or a different bucket and account for prod):
  #
  # backend "s3" {
  #   bucket       = "<your-state-bucket>"
  #   key          = "week5/dev/terraform.tfstate"
  #   region       = "us-east-1"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "week5"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name                 = "week5-dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "web_tier" {
  source = "../../modules/web-tier"

  project_name      = "week5-dev"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = "t3.micro"
  asg_min           = 1
  asg_max           = 2
  asg_desired       = 1
}
