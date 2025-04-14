variable "alb_name" {
  description = "The name of the ALB."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ALB will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the ALB."
  type        = map(string)
}

variable "public_subnet" {
  description = "A list of public subnet IDs where the ALB will be created."
  type        = list(string)
}

variable "enable_alb_deletion" {
  description = "Enable deletion protection for the ALB."
  type        = bool
}