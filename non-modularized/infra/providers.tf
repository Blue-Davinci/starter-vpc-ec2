terraform {
  backend "s3" {
    bucket       = "starter-vpc-ec2-terraform-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true # Enable server-side encryption
    use_lockfile = true # Enable state locking without the need for a DynamoDB table
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.11.1"
}

provider "aws" {
  region = var.provider_region
}