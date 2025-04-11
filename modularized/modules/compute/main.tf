# Create a security group to hook up with our ec2 instance
resource "aws_security_group" "starter-vpc-ec2-sg" {
  name        = "starter-vpc-ec2-sg"
  description = "Security group for the EC2 instance allowing only http"
  vpc_id      = var.vpc_id
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
  subnet_id              = var.subnet_id
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