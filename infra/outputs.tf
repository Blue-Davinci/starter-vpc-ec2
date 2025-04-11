output "vpc_id" {
  value = aws_vpc.starter-vpc-ec2.id
  description = "The ID of the VPC"
}

output "vpc_name" {
  value = aws_vpc.starter-vpc-ec2.tags["Name"]
  description = "The name of the created VPC" 
}

output "igw_id" {
  value = aws_internet_gateway.starter-vpc-ec2-igw.id
  description = "The ID of the Internet Gateway"
}