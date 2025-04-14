output "web_app_urls_with_ips" {
  description = "URLs and Public IPs of the EC2 instances"
  value       = [for instance in aws_instance.starter-vpc-ec2-simple-web : "http://${instance.public_ip} (IP: ${instance.public_ip})"]
}

# The instance ID's of our EC2 instances
output "ec2_instance_ids" {
  description = "The instance ID of the EC2 instance"
  value       = aws_instance.starter-vpc-ec2-simple-web[*].id
}