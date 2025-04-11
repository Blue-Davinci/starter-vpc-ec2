output "vpc_id" {
  value       = aws_vpc.starter-vpc-ec2.id
  description = "The ID of the VPC"
}

output "vpc_name" {
  value       = aws_vpc.starter-vpc-ec2.tags["Name"]
  description = "The name of the created VPC"
}

output "igw_id" {
  value       = aws_internet_gateway.starter-vpc-ec2-igw.id
  description = "The ID of the Internet Gateway"
}

output "web_app_url" {
  description = "URL to access the web application"
  value       = "http://${aws_instance.starter-vpc-ec2-simple-web.public_ip}"
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.starter-vpc-ec2-simple-web.public_ip
}