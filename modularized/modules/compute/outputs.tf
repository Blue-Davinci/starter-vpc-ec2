output "web_app_url" {
  description = "URL to access the web application"
  value       = "http://${aws_instance.starter-vpc-ec2-simple-web.public_ip}"
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.starter-vpc-ec2-simple-web.public_ip
}