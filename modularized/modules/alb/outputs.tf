# pass down the alb sg id
output "alb_sg_id" {
  value = aws_security_group.starter-vpc-ec2-alb-sg.id
  description = "The security group ID of the ALB"
}

# The ARN of the target group
output "target_group_arn" {
  value = aws_lb_target_group.starter-vpc-ec2-tg.arn
  description = "The ARN of the target group"
}

# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.starter-vpc-ec2-alb.dns_name
  description = "The DNS name of the ALB"
}

# Output the tracking resource label for the target tracking scaling policy
output "target_tracking_resource_label" {
  value = "${replace(aws_lb.starter-vpc-ec2-alb.arn_suffix, "loadbalancer/", "app/")}/${aws_lb_target_group.starter-vpc-ec2-tg.arn_suffix}"
  description = "The resource label for the target tracking scaling policy"
}

# target_group_arn_suffix
output "target_group_arn_suffix" {
  value = aws_lb_target_group.starter-vpc-ec2-tg.arn_suffix
  description = "The target group ARN suffix for the ALB"
}

# alb_arn_suffix
output "alb_arn_suffix" {
  value = aws_lb.starter-vpc-ec2-alb.arn_suffix
  description = "The ARN suffix of the ALB"
}