/*
This will be responsible for creating the infrastructure itself which will
include:
    - VPC
    - 4 subnets (2 public and 2 private)
    - Internet Gateway
    - Route Tables for public and private subnets
    - Security Groups
    - EC2 instance in the public subnet
For the sake if simplicity, we will not be using any modules in this example.
We will be creating the resources in the same file. This is not a good practice but for the sake of simplicity, we will do it this way. 
In the "modularized_infra" setup, we will use modules to create reusable code.
*/
resource "aws_vpc" "starter-vpc-ec2" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = merge(var.tags, { Name = "starter-vpc-ec2-vpc" })
}

# Create an internet gateway attaching it to the VPC
# We will associate the public subnets with this internet gateway
# This will allow the public subnets to have internet access
resource "aws_internet_gateway" "starter-vpc-ec2-igw" {
  vpc_id = aws_vpc.starter-vpc-ec2.id
  tags = merge(var.tags, { Name = "starter-vpc-ec2-igw" })
}

# create our subnets using the variables to supply their CIDR blocks
# as well as the availability zones
resource "aws_subnet" "starter-vpc-ec2-public-subnet" {
    count = length(var.aws_public_subnet_cidrs)
    vpc_id = aws_vpc.starter-vpc-ec2.id
    cidr_block = element(var.aws_public_subnet_cidrs, count.index)
    availability_zone = element(var.aws_availability_zones, count.index)
    map_public_ip_on_launch = true # This will assign a public IP to the instances in this subnet
    tags = merge(var.tags, {Name = "starter-vpc-ec2-public-subnet-${count.index + 1}"})
}

# Create the private subnets using the variables to supply their CIDR blocks
# as well as the availability zones
resource "aws_subnet" "starter-vpc-ec2-private-subnet" {
    count = length(var.aws_private_subnet_cidrs)
    vpc_id = aws_vpc.starter-vpc-ec2.id
    cidr_block = element(var.aws_private_subnet_cidrs, count.index)
    availability_zone = element(var.aws_availability_zones, count.index)
    tags = merge(var.tags, {Name = "starter-vpc-ec2-private-subnet-${count.index + 1}"})
    # we won't assign public IPs to the instances in this subnet
    # so we don't need to set map_public_ip_on_launch to true
}
