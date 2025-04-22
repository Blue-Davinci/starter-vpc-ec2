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
    # count = 1 # Create one EIP per
    tags = merge(var.tags, { Name = "starter-vpc-ec2-nat-eip" })
}

# Create a NAT Gateway in each public subnet
resource "aws_nat_gateway" "starter-vpc-ec2-nat-gateway" {
    /*
    count         = length(var.public_subnet_ids)
    allocation_id = aws_eip.starter-vpc-ec2-nat-eip[count.index].id # Use the EIP created above
    subnet_id     = element(var.public_subnet_ids, count.index) # Use the public subnet ID
    */
    allocation_id = aws_eip.starter-vpc-ec2-nat-eip.id # Use the EIP created above
    subnet_id     = var.public_subnet_ids[0] # Use the first public subnet ID
    tags          = merge(var.tags, { Name = "starter-vpc-ec2-nat-gateway-main" })
}

