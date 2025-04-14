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