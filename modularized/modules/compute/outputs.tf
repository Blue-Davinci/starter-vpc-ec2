# ASG name
output "asg_name" {
  description = "The name of our ASG"
  value = aws_autoscaling_group.starter-vpc-ec2-asg.name
}
