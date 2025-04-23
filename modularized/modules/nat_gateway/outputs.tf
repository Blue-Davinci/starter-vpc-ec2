# Nat Gatewa ids are passed to the private route table to route traffic to the NAT Gateway in the same AZ as the private subnet.
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  #   value       = aws_nat_gateway.starter-vpc-ec2-nat-gateway[*].id
  value       = aws_nat_gateway.starter-vpc-ec2-nat-gateway[*].id # shift to a single nat gateway for now
}