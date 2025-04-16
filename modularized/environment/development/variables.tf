variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "starter-vpc-ec2"
    Owner       = "blue"
  }
}

variable "provider_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "instance_ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-00a929b66ed6e0de6" # Amazon Linux 2 AMI (us-east-1)
}

## Create a terraform.tfvars file in the same directory as this file and add the following variables in the following format:
# email_address = "foo@bar.xxx"
variable "email_address" {
  description = "value of the email address to subscribe to the SNS topic"
  type        = string
  sensitive = true
}