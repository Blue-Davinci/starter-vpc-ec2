#!/bin/bash
set -e

# ----------------------------
# Update system and install tools
# ----------------------------
dnf update -y
dnf install -y wget git curl amazon-cloudwatch-agent systemd

# ----------------------------
# Install Amazon Corretto 17 (Java 17)
# ----------------------------
rpm --import https://yum.corretto.aws/corretto.key
curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
dnf install -y java-17-amazon-corretto

# ----------------------------
# Install Jenkins (latest LTS)
# ----------------------------
curl -Lo /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf install -y jenkins

# ----------------------------
# Enable and Start Jenkins
# ----------------------------
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# ----------------------------
# Install and Configure SSM Agent
# ----------------------------
dnf install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# ----------------------------
# Get EC2 Instance ID (IMDSv2 Safe)
# ----------------------------
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300" || true)
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/instance-id" || curl -s "http://169.254.169.254/latest/meta-data/instance-id")

# ----------------------------
# Configure CloudWatch Agent
# ----------------------------
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


# ----------------------------
# Start and Enable CloudWatch Agent
# ----------------------------
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

systemctl enable amazon-cloudwatch-agent
