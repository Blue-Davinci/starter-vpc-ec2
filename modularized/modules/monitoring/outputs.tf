# The ARN for the sns topic
output "sns_topic_arn" {
  value = aws_sns_topic.alarm_topic.arn
}

# sns subscription email output
output "sns_subscription_email" {
  value = aws_sns_topic_subscription.alarm_email_subscription.endpoint
}
