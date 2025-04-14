terraform {
  backend "s3" {
    bucket       = "starter-vpc-ec2-terraform-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true # Enable server-side encryption
    use_lockfile = true # Enable state locking without the need for a DynamoDB table
  }
}