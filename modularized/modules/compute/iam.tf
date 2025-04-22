# Create an IAM role which will allow a service (ec2 instance) to assume the role and perform actions on behalf of the user.
resource "aws_iam_role" "starter-vpc-ec2-ssm-role" {
  name = "${var.tags["Project"]}-${var.tags["Environment"]}-ec2-ssm-role-${random_string.launch_template.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })
  tags = merge(var.tags, { Name = "starter-vpc-ec2-ssm-role" })
}

# Attach the AmazonSSMManagedInstanceCore policy to the role allowing 
# our ec2 instance to communicate with SSM (AWS Systems Manager)
resource "aws_iam_role_policy_attachment" "ssm-ec2-attach" {
  role       = aws_iam_role.starter-vpc-ec2-ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the CloudWatch Agent policy to enable logging to CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch-agent-attach" {
  role       = aws_iam_role.starter-vpc-ec2-ssm-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
