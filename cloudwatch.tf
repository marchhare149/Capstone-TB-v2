
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "${var.project_name}-asg-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 300
  threshold           = 70
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  alarm_name          = "${var.project_name}-rds-free-storage-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 300
  threshold           = 2147483648
  statistic           = "Average"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}