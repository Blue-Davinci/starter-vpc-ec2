/* Because we have changed the setup and the EC2's are in the private subnet
 We will not output the public IPs of the EC2 instances. Instead, we will output the ALB DNS name and the private IPs of the EC2 instances.
output "web_app_urls_with_ips" {
  description = "URL to access the web application"
  value       = module.compute.web_app_urls_with_ips
}
*/

# Output some settings like region, use_single_nat_gateway, instance type, and instance ami
output "region" {
  description = "The AWS region we are using"
  value       = var.provider_region
}

output "use_single_nat_gateway" {
  description = "Whether we are using a single NAT Gateway or not"
  value       = var.use_single_nat_gateway 
}

output "instance_type" {
  description = "The type of EC2 instance we are using"
  value       = var.instance_type
}

output "name_of_instance_ami" {
  description = "The AMI ID we are using"
  value       = var.instance_ami
  
}

output "alb_dns_name" {
  description = "value of the ALB DNS name"
  value       = "http://${module.alb.alb_dns_name}"
}

output "asg_name" {
  description = "The name of our ASG"
  value       = module.compute.asg_name
}
