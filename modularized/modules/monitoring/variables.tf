#target_group_arn_suffix
variable "target_group_arn_suffix" {
  description = "The target group ARN suffix for the ALB"
  type        = string
}

# alb_arn_suffix
variable "alb_arn_suffix" {
  description = "The ARN suffix of the ALB"
  type        = string
}

# tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

# ASG Name
variable "asg_name" {
  description = "The name of our ASG"
  type = string
}

# Email address
variable "email_address" {
  description = "The email address to subscribe to the SNS topic"
  type        = string
  sensitive   = true
}

# provider region
variable "aws_region" {
  description = "The AWS region to deploy the resources in"
  type        = string
}
