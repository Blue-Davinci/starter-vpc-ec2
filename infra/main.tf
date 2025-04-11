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
  vpc_id = aws_vpc.starter-vpc-ec2.id
  tags   = merge(var.tags, { Name = "starter-vpc-ec2-private-rt" })
  # No routes needed for private subnets, they will use the default route table
}

# Create route associations for the public subnets
resource "aws_route_table_association" "starter-vpc-ec2-public-rt-assoc" {
  count          = length(aws_subnet.starter-vpc-ec2-public-subnet)
  subnet_id      = aws_subnet.starter-vpc-ec2-public-subnet[count.index].id
  route_table_id = aws_route_table.starter-vpc-ec2-public-rt.id
}

# Create route associations for the private subnets
resource "aws_route_table_association" "starter-vpc-ec2-private-rt-assoc" {
  count          = length(aws_subnet.starter-vpc-ec2-private-subnet)
  subnet_id      = aws_subnet.starter-vpc-ec2-private-subnet[count.index].id
  route_table_id = aws_route_table.starter-vpc-ec2-private-rt.id
}

# Create a security group to hook up with our ec2 instance
resource "aws_security_group" "starter-vpc-ec2-sg" {
  name        = "starter-vpc-ec2-sg"
  description = "Security group for the EC2 instance allowing only http"
  vpc_id      = aws_vpc.starter-vpc-ec2.id
  # ingress for port 80 (http) from anywhere
  ingress {
    description      = "Allow HTTP traffic on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false # This is not a self-referencing security group
  }
  # egress for all traffic to anywhere
  egress {
    description      = "Allow all outbound traffic from anywhere"
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # -1 means all protocols
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
  tags = merge(var.tags, { Name = "starter-vpc-ec2-sg" })
}

/*
# Finally let us create an EC2 instance in the public subnet 
# For the server, and for simplicity, we will create a simple server using user data
# to install httpd and start the service with a custom html page
# No ssh access will be allowed for now, but we will add it later
# Meta we will use: 
    - T2 micro instance type (var.instance_type)
    - Amzon linux AMI
*/
resource "aws_instance" "starter-vpc-ec2-simple-web" {
  ami                    = "ami-00a929b66ed6e0de6" # Amazon Linux 2 AMI (us-east-1)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.starter-vpc-ec2-sg.id]
  subnet_id              = aws_subnet.starter-vpc-ec2-public-subnet[0].id
  key_name               = var.key_name
  user_data              = <<-EOF
                #!/bin/bash
                # Ensure script exits on error
                set -e
                
                # Update and install Apache
                yum update -y
                yum install -y httpd
                
                # Create custom index.html with dynamic tags
                cat > /var/www/html/index.html <<EOT
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <title>${var.tags["Project"]} - Web Server</title>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 40px; }
                        h1 { color: #2c3e50; }
                        .info { background: #f4f4f4; padding: 20px; border-radius: 5px; }
                    </style>
                </head>
                <body>
                    <h1>Hello from Terraform!</h1>
                    <div class="info">
                        <p><strong>Environment:</strong> ${var.tags["Environment"]}</p>
                        <p><strong>Project:</strong> ${var.tags["Project"]}</p>
                        <p><strong>Owner:</strong> ${var.tags["Owner"]}</p>
                    </div>
                </body>
                </html>
                EOT
                
                # Start and enable Apache
                systemctl start httpd
                systemctl enable httpd
                EOF

  tags = merge(var.tags, { Name = "starter-vpc-ec2-simple-web" })
}