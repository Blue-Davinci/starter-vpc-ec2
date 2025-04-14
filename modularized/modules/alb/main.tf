/*
This module will be responsible for the creation of an ALB.
We will create the following resources:
1. A Target Group for the ALB to route traffic to the EC2 instances.
2. An ALB that will route traffic to the Target Group.
3. A Listener for the ALB that will listen for incoming traffic on port 80 and route it to the Target Group.
4. A security group for the ALB that will allow incoming traffic on port 80 from the internet.
*/

resource "aws_lb_target_group" "starter-vpc-ec2-tg" {
  name     = "${var.alb_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/" # Health check path for the target group
    protocol            = "HTTP"
    matcher             = "200-299" # Accept 2xx responses as healthy
    interval            = 30
    timeout             = 5
    healthy_threshold  = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-tg"
    }
  )
  
}

# we should have an association here, but this will cause a chicken and egg problem
# so we will create the association in the main.tf file of the root module

# ALB security group
resource "aws_security_group" "starter-vpc-ec2-alb-sg" {
    name = "${var.alb_name}-sg"
    description = "Allow HTTP inbound traffic"
    vpc_id = var.vpc_id
    # rules
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
}

# Create the ALB itself
resource "aws_lb" "starter-vpc-ec2-alb" {
  name               = "${var.alb_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.starter-vpc-ec2-alb-sg.id]
  subnets            = var.public_subnet

  enable_deletion_protection = var.enable_alb_deletion # Variable to control this depending on ENV 
  enable_cross_zone_load_balancing = true # Enable cross-zone load balancing

  enable_http2 = true # Allow HTTP/2 connections for better performance/multiplexing

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-alb"
    }
  )
  
}

# Create the ALB listener
resource "aws_lb_listener" "starter-vpc-ec2-alb-listener" {
    load_balancer_arn = aws_lb.starter-vpc-ec2-alb.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.starter-vpc-ec2-tg.arn
    }

}