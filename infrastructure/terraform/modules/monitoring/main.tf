# SNS Topic for Alarms
resource "aws_sns_topic" "alerts" {
  name = "shopcloud-alerts-${var.env}"

  tags = {
    Name = "shopcloud-alerts-${var.env}"
    Env  = var.env
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}

# ALB 5xx Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "shopcloud-${var.env}-alb-high-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when ALB 5xx errors exceed threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name = "shopcloud-${var.env}-alb-high-5xx"
    Env  = var.env
  }
}

# ALB High Latency
resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  alarm_name          = "shopcloud-${var.env}-alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "2.0"
  alarm_description   = "Alert when ALB response time exceeds 2 seconds"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name = "shopcloud-${var.env}-alb-high-latency"
    Env  = var.env
  }
}

# Unhealthy Targets
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "shopcloud-${var.env}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when ALB has unhealthy targets"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = {
    Name = "shopcloud-${var.env}-alb-unhealthy-hosts"
    Env  = var.env
  }
}

# ECS CPU and Memory per Service
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  for_each = toset(var.services)

  alarm_name          = "shopcloud-${var.env}-${each.value}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when ${each.value} CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "shopcloud-${each.value}-${var.env}"
  }

  tags = {
    Name = "shopcloud-${var.env}-${each.value}-cpu-high"
    Env  = var.env
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  for_each = toset(var.services)

  alarm_name          = "shopcloud-${var.env}-${each.value}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when ${each.value} memory exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = "shopcloud-${each.value}-${var.env}"
  }

  tags = {
    Name = "shopcloud-${var.env}-${each.value}-memory-high"
    Env  = var.env
  }
}

# RDS CPU
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "shopcloud-${var.env}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }

  tags = {
    Name = "shopcloud-${var.env}-rds-cpu-high"
    Env  = var.env
  }
}

# RDS Connections
resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name          = "shopcloud-${var.env}-rds-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "100"
  alarm_description   = "Alert when RDS connections exceed 100"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBClusterIdentifier = var.rds_cluster_id
  }

  tags = {
    Name = "shopcloud-${var.env}-rds-connections-high"
    Env  = var.env
  }
}

# DynamoDB Read/Write Throttling
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttle" {
  alarm_name          = "shopcloud-${var.env}-dynamodb-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedWriteCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "40"
  alarm_description   = "Alert when DynamoDB writes are throttled"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  tags = {
    Name = "shopcloud-${var.env}-dynamodb-throttle"
    Env  = var.env
  }
}

# SQS DLQ Messages (only if queue names provided)
resource "aws_cloudwatch_metric_alarm" "sqs_dlq" {
  count               = var.sqs_dlq_name != "" ? 1 : 0
  alarm_name          = "shopcloud-${var.env}-sqs-dlq-messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Alert when SQS DLQ has messages"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    QueueName = var.sqs_dlq_name
  }

  tags = {
    Name = "shopcloud-${var.env}-sqs-dlq-messages"
    Env  = var.env
  }
}
