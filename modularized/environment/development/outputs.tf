output "web_app_url" {
  description = "URL to access the web application"
  value       = module.compute.web_app_url
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.compute.ec2_instance_public_ip
}