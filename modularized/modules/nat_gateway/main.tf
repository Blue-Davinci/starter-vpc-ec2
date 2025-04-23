/* 
We create a NAT gateway which will allow our private subnets to access the internet
and download packages/ setup our test server.
Resources we will create:
1. EIP for the NAT gateway so that it can be accessed from the internet
2. Nat gtaeway itself
3. A route table hooking the VPC to the NAT gateway
4. A route table association for the private subnets to use the NAT gateway
*/
# Create an EIP in each public subnet for the NAT Gateway
resource "aws_eip" "starter-vpc-ec2-nat-eip" {
    # Removed deprecated 'vpc' argument as it is no longer required
    count = var.use_single_nat_gateway ? 1 : length(var.public_subnet_ids) # Create one EIP if using a single NAT Gateway, otherwise create one for each public subnet
    tags = merge(var.tags, { Name = "starter-vpc-ec2-nat-eip-${count.index + 1}" })
}

# Create a NAT Gateway in each public subnet
resource "aws_nat_gateway" "starter-vpc-ec2-nat-gateway" {
    count         = var.use_single_nat_gateway ? 1 : length(var.public_subnet_ids) # if using a single NAT Gateway, create one, otherwise create one for each public subnet
    allocation_id = aws_eip.starter-vpc-ec2-nat-eip[count.index].id # Ensure each NAT Gateway gets a unique EIP
    subnet_id     = var.use_single_nat_gateway ? var.public_subnet_ids[0]: var.public_subnet_ids[count.index]
    tags          = merge(var.tags, { Name = "starter-vpc-ec2-nat-gateway-main-${count.index + 1}" })
}

