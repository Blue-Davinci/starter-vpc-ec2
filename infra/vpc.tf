/*
# This file contains the VPC resource definition for the AWS infrastructure.
# It creates a VPC with the specified CIDR block and enables DNS support and hostnames.
# It also creates an Internet Gateway and associates it with the VPC.

resource "aws_vpc" "starter-vpc-ec2" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = var.tags
}

resource "aws_internet_gateway" "starter-vpc-ec2-igw" {
  vpc_id = aws_vpc.starter-vpc-ec2.id
  tags = merge(var.tags, { Name = "starter-vpc-ec2-igw" })
}
*/