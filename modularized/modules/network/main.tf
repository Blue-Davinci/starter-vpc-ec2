resource "aws_vpc" "starter-vpc-ec2" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "starter-vpc-ec2-vpc" })
}

# Create an internet gateway attaching it to the VPC
# We will associate the public subnets with this internet gateway
# This will allow the public subnets to have internet access
resource "aws_internet_gateway" "starter-vpc-ec2-igw" {
  vpc_id = aws_vpc.starter-vpc-ec2.id
  tags   = merge(var.tags, { Name = "starter-vpc-ec2-igw" })
}

# create our subnets using the variables to supply their CIDR blocks
# as well as the availability zones
resource "aws_subnet" "starter-vpc-ec2-public-subnet" {
  count                   = length(var.aws_public_subnet_cidrs)
  vpc_id                  = aws_vpc.starter-vpc-ec2.id
  cidr_block              = element(var.aws_public_subnet_cidrs, count.index)
  availability_zone       = element(var.aws_availability_zones, count.index)
  map_public_ip_on_launch = true # This will assign a public IP to the instances in this subnet
  tags                    = merge(var.tags, { Name = "starter-vpc-ec2-public-subnet-${count.index + 1}" })
}

# Create the private subnets using the variables to supply their CIDR blocks
# as well as the availability zones
resource "aws_subnet" "starter-vpc-ec2-private-subnet" {
  count             = length(var.aws_private_subnet_cidrs)
  vpc_id            = aws_vpc.starter-vpc-ec2.id
  cidr_block        = element(var.aws_private_subnet_cidrs, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)
  tags              = merge(var.tags, { Name = "starter-vpc-ec2-private-subnet-${count.index + 1}" })
  # we won't assign public IPs to the instances in this subnet
  # so we don't need to set map_public_ip_on_launch to true
}

# Create the route table for the public subnet, hooking it to the IGW we created above
resource "aws_route_table" "starter-vpc-ec2-public-rt" {
  vpc_id = aws_vpc.starter-vpc-ec2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.starter-vpc-ec2-igw.id
  }
  tags = merge(var.tags, { Name = "starter-vpc-ec2-public-rt" })
}

# Create private route table
resource "aws_route_table" "starter-vpc-ec2-private-rt" {
  count  = length(aws_subnet.starter-vpc-ec2-private-subnet) # One route table per private subnet
  vpc_id = aws_vpc.starter-vpc-ec2.id
  tags   = merge(var.tags, { Name = "starter-vpc-ec2-private-rt-${count.index + 1}" })
  

  # Route to the NAT Gateway in the same AZ
  route {
    cidr_block     = "0.0.0.0/0"
    # if single nat gateway bool is yes, then use the first nat gateway id otherwise use the nat gateway id for the current index
    nat_gateway_id = var.use_single_nat_gateway ? aws_nat_gateway.starter-vpc-ec2-nat-gateway[0].id : aws_nat_gateway.starter-vpc-ec2-nat-gateway[count.index].id
  }
}

# Create route associations for the public subnets
resource "aws_route_table_association" "starter-vpc-ec2-public-rt-assoc" {
  count          = length(aws_subnet.starter-vpc-ec2-public-subnet)
  subnet_id      = aws_subnet.starter-vpc-ec2-public-subnet[count.index].id
  route_table_id = aws_route_table.starter-vpc-ec2-private-rt[count.index].id
}

# Create route associations for the private subnets
resource "aws_route_table_association" "starter-vpc-ec2-private-rt-assoc" {
  count          = length(aws_subnet.starter-vpc-ec2-private-subnet)
  subnet_id      = aws_subnet.starter-vpc-ec2-private-subnet[count.index].id
  route_table_id = aws_route_table.starter-vpc-ec2-private-rt[count.index].id
}
