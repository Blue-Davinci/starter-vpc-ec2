# VPC ID
variable "vpc_id" {
  description = "The ID of the VPC to launch the instance in"
  type        = string  
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}


# Key Name for ssh, will be disabled for now
variable "key_name" {
  description = "The name of the key pair to use for SSH access to the instances"
  type        = string
  default     = null # Set to null to disable SSH access
}

# ALB sg id
variable "alb_sg_id" {
  description = "The security group ID of the ALB"
  type        = string
}

# ALB target group ARN
variable "target_group_arn" {
  description = "The target group ARN of the ALB"
  type        = string
}

# target_tracking_resource_label
variable "target_tracking_resource_label" {
  description = "The resource label for the target tracking scaling policy"
  type        = string
}

# EC2 type
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

# instance ami
variable "ami" {
  description = "The AMI of our instance"
  type = string
}

# EC2 subnet
variable "private_subnet_ids" {
  description = "A list of the private subnet IDs to launch the instance in"
  type        = list(string)
} 

# EC2 ami
variable "instance_ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

