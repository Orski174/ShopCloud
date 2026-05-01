output "sns_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS topic ARN for alerts"
}

output "alarm_arns" {
  value = {
    alb_5xx              = aws_cloudwatch_metric_alarm.alb_5xx.arn
    alb_latency          = aws_cloudwatch_metric_alarm.alb_latency.arn
    unhealthy_hosts      = aws_cloudwatch_metric_alarm.unhealthy_hosts.arn
    rds_cpu              = aws_cloudwatch_metric_alarm.rds_cpu.arn
    rds_connections      = aws_cloudwatch_metric_alarm.rds_connections.arn
    dynamodb_throttle    = aws_cloudwatch_metric_alarm.dynamodb_throttle.arn
  }
  description = "Map of alarm names to ARNs"
}
