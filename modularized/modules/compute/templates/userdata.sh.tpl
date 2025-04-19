#!/bin/bash
set -e

# Update system and install Apache
yum update -y
yum install -y httpd

# Install Amazon SSM Agent (already pre-installed on Amazon Linux 2, but ensure latest version)
yum install -y amazon-ssm-agent

# Enable and start the SSM Agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Retrieve the instance ID from AWS metadata using IMDSv2 (fallback to IMDSv1)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  "http://169.254.169.254/latest/meta-data/instance-id" || \
  curl -s "http://169.254.169.254/latest/meta-data/instance-id")

# Generate index.html for Apache
cat > /var/www/html/index.html <<EOT
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>${project} - Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 40px; }
        h1 { color: #2c3e50; }
        .info { background: #f4f4f4; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Hello from Terraform! This is EC2 instance $${INSTANCE_ID}</h1>
    <div class="info">
        <p><strong>Environment:</strong> ${environment}</p>
        <p><strong>Project:</strong> ${project}</p>
        <p><strong>Owner:</strong> ${owner}</p>
    </div>
</body>
</html>
EOT

# Start and enable Apache
systemctl start httpd
systemctl enable httpd
