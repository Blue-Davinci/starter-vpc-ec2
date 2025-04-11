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