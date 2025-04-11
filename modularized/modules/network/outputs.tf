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

output "public_subnet_ids" {
  value = aws_subnet.starter-vpc-ec2-public-subnet[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value = aws_subnet.starter-vpc-ec2-private-subnet[*].id
  description = "List of private subnet IDs"
}