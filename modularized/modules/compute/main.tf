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
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = [var.alb_sg_id]
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
# Now, we need to move to an Auto-Scaler, we will not need a fixed instance.
# We will add the following:
# 1. A launch template for the auto-scaler to specify the AMI, instance type, and security group.
# 2. Auto- scaler group to manage the instances, pointing to the above sg
# 3. An random string generator to pass to our user data template
*/

resource "aws_launch_template" "starter-vpc-ec2-lt" {
  name_prefix = "${var.tags["Environment"]}-${random_string.launch_template.result}-lt-"
  image_id = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids =  [aws_security_group.starter-vpc-ec2-sg.id]
  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tpl", {
    environment = var.tags["Environment"]
    project = var.tags["Project"]
    owner = var.tags["Owner"]
  }))
  lifecycle {
    create_before_destroy = true # create a resource before destroying an old one
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, { Name = "starter-vpc-ec2-simple-web-${random_string.launch_template.result}" })
  }
}


# ASG to manage the above templated instances
resource "aws_autoscaling_group" "starter-vpc-ec2-asg" {
  name = "${var.tags["Environment"]}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity = 2
  max_size = 3
  min_size = 1
  health_check_type = "EC2"
  health_check_grace_period = 300
  target_group_arns = [var.target_group_arn]

  launch_template {
    id = aws_launch_template.starter-vpc-ec2-lt.id
    # ToDo: consider making this a var especially in Prod as
    # latest can cause issues inase of problems with template
    # maybe use a specific version, maybe 1?
    version = "$Latest"
  }
  tag {
    key = "Name"
    value               = "${var.tags["Environment"]}-${random_string.launch_template.result}-asg"
    propagate_at_launch = true # propagate the tag to instances launched by the ASG
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create a random string resource to help just keep track of the current infra
# setup round.
resource "random_string" "launch_template" {
  length = 8
  special = false
  upper = true
  lower = true
  numeric = true
}

# make a policy to scale up and down the ASG using Target Tracking
# we will use ALBRequestCountPerTargetas the metric to scale on
resource "aws_autoscaling_policy" "starter-vpc-asg-policy-alb" {
  name = "starter-vpc-asg-alb-policy-${var.tags["Environment"]}-${random_string.launch_template.result}"
  autoscaling_group_name = aws_autoscaling_group.starter-vpc-ec2-asg.name
  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      # expected format: app/load-balancer-name/load-balancer-id/targetgroup/target-group-name/target-group-id
      resource_label         = var.target_tracking_resource_label
    }
    target_value = 100 # Each instance should handle 100 requests per second
    disable_scale_in = false
  }
}


