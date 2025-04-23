# Create cloud watch alarm monitor for High load warning
resource "aws_cloudwatch_metric_alarm" "high_request_alarm" {
  alarm_name = "high-request-alarm-${var.tags["Environment"]}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  period = 60
  metric_name = "RequestCountPerTarget"
  namespace = "AWS/ApplicationELB"
  statistic = "Sum" # Sum of requests over the period
  threshold = 200 # Set the threshold for high load
  alarm_description = "Alarm when request count per target exceeds 200"
  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn] # List of actions to take when alarm is triggered
  
}

# Create cloud watch alarm for Low Traffic alarms
resource "aws_cloudwatch_metric_alarm" "low_request_alarm" {
  alarm_name = "low-request-alarm-${var.tags["Environment"]}}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2 # Evaluate over 2 periods. This means the alarm will trigger if the condition is met for 2 consecutive periods
  period = 60 # Period in seconds
  metric_name = "RequestCountPerTarget"
  namespace = "AWS/ApplicationELB"
  statistic = "Sum" # Sum of requests over the period
  threshold = 20 # Less than 20 requests per target
  alarm_description = "Alarm when request count per target is less than 200"
  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
  
}

# Create a cloud watch alarm for ec2 instance availability/health
resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed"{
  alarm_name = "ec2-status-check-failed-${var.tags["Environment"]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2 # Evaluate over 2 periods. This means the alarm will trigger if the condition is met for 2 consecutive periods
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60 # Period in seconds
  statistic           = "Average" # Average of the status check failed metric over the period
  threshold           = 0 # Set the threshold for the alarm. 0 means that if any instance fails the status check, the alarm will trigger
  alarm_description   = "One or more EC2 instances failed status checks"
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]# List of actions to take when alarm is triggered
}

# ================= Alarms ===============================================
# Create SNS Topic
resource "aws_sns_topic" "alarm_topic" {
    name = "alarm-topic-${var.tags["Environment"]}"
}

# Create a subscription. We will be using a supplied Email
resource "aws_sns_topic_subscription" "alarm_email_subscription" {
    topic_arn = aws_sns_topic.alarm_topic.arn
    protocol = "email"
    endpoint = var.email_address # The email address to subscribe to the SNS topic
    # You can also use "lambda" or "sqs" as the protocol if you want to send the alarm notifications to a Lambda function or SQS queue
    # respectively. Https and application are examples of other endpoints.
}


# ================== Dashboard ===============================================

resource "aws_cloudwatch_dashboard" "apache_asg_dashboard" {
  dashboard_name = "${var.tags["Project"]}-${var.tags["Environment"]}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ========== Average CPU Utilization for ASG ==========
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          view    = "timeSeries",
          region  = var.aws_region,
          title   = "ASG Average CPU Utilization",
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]
          ],
          stat   = "Average",
          period = 300
        }
      },

      # ========== Apache Access Log Count ==========
      {
        type   = "log",
        x      = 0,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          query  = <<EOT
SOURCE '/ec2/${var.tags["Environment"]}/apache-logs'
| fields @timestamp, @message
| filter @logStream like /access/
| stats count() as requests by bin(5m)
EOT
          region = var.aws_region,
          title  = "Apache Access Logs - Request Count (5m)"
        }
      },

      # ========== Apache Error Log Summary ==========
      {
        type   = "log",
        x      = 12,
        y      = 6,
        width  = 12,
        height = 6,
        properties = {
          query  = <<EOT
SOURCE '/ec2/${var.tags["Environment"]}/apache-logs'
| fields @timestamp, @message
| filter @logStream like /error/
| sort @timestamp desc
| limit 20
EOT
          region = var.aws_region,
          title  = "Apache Error Logs - Last 20 Entries"
        }
      },

      # ========== CloudInit Boot Logs ==========
      {
        type   = "log",
        x      = 0,
        y      = 12,
        width  = 24,
        height = 6,
        properties = {
          query  = <<EOT
SOURCE '/ec2/${var.tags["Environment"]}/cloudinit-logs'
| fields @timestamp, @message
| sort @timestamp desc
| limit 10
EOT
          region = var.aws_region,
          title  = "CloudInit Logs - Recent Boot Events"
        }
      }
    ]
  })
}
