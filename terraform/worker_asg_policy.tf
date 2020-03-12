# scale up alarm

resource "aws_autoscaling_policy" "worker-cpu-policy" {
  name                   = "worker-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.worker-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "worker-cpu-alarm" {
  alarm_name          = "worker-cpu-alarm"
  alarm_description   = "worker-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.worker-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.worker-cpu-policy.arn]
}

# scale down alarm
resource "aws_autoscaling_policy" "worker-cpu-policy-scaledown" {
  name                   = "worker-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.worker-autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "worker-cpu-alarm-scaledown" {
  alarm_name          = "worker-cpu-alarm-scaledown"
  alarm_description   = "worker-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.worker-autoscaling.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.worker-cpu-policy-scaledown.arn]
}

