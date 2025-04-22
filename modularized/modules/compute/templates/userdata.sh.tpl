#!/bin/bash
set -e

# Update and install required packages
yum update -y
amazon-linux-extras install java-openjdk11 -y
yum install -y wget git amazon-cloudwatch-agent

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Get Instance ID (IMDSv2 safe)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/instance-id" || curl -s "http://169.254.169.254/latest/meta-data/instance-id")

# =======================
# CloudWatch Agent Config
# =======================

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWCONFIG
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/jenkins/jenkins.log",
            "log_group_name": "/ec2/${environment}/jenkins-logs",
            "log_stream_name": "$${INSTANCE_ID}-jenkins"
          },
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "/ec2/${environment}/cloudinit-logs",
            "log_stream_name": "$${INSTANCE_ID}-cloudinit"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "/ec2/${environment}/cloudinit-logs",
            "log_stream_name": "$${INSTANCE_ID}-cloudinit-output"
          }
        ]
      }
    }
  }
}
CWCONFIG

# Start and enable CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

systemctl enable amazon-cloudwatch-agent
