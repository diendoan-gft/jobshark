#####################################
# JobShark EC2 Autoscale policy
#####################################

locals {
  jobshark_policy_settings = {
    "jobshark_policy_scale_down" = {
      name               = "${var.env}-${var.short_region}-CPU-Scale-Down-Policies"
      scaling_adjustment = -1,
      cooldown           = 600,
      adjustment_type    = "ChangeInCapacity"
    },
    "jobshark_policy_scale_up" = {
      name               = "${var.env}-${var.short_region}-CPU-Scale-Up-Policies"
      scaling_adjustment = 1,
      cooldown           = 1200,
      adjustment_type    = "ChangeInCapacity"
    }
  }
}

resource "aws_autoscaling_policy" "ec2_autoscale_policy" {
  for_each               = local.jobshark_policy_settings
  name                   = each.value.name
  scaling_adjustment     = each.value.scaling_adjustment
  adjustment_type        = each.value.adjustment_type
  cooldown               = each.value.cooldown
  autoscaling_group_name = module.ec2_asg.autoscaling_group_name
  depends_on = [
    module.ec2_asg,
  ]
}

#####################################
# JobShark EC2 Cloud Watch
#####################################

resource "aws_cloudwatch_metric_alarm" "cpu-scale-down-policy" {
  alarm_name          = "${var.env}-${var.short_region}-cpu-scale-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "25"
  depends_on = [
    module.ec2_asg,
  ]
  dimensions = {
    AutoScalingGroupName = module.ec2_asg.autoscaling_group_name
  }

  alarm_description = "Scale Down alarm when CPU in autoscale group is below 25%"
  alarm_actions     = [aws_autoscaling_policy.ec2_autoscale_policy["jobshark_policy_scale_down"].arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-scale-up-alarm" {
  alarm_name          = "${var.env}-${var.short_region}-cpu-scale-up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  depends_on = [
    module.ec2_asg,
  ]
  dimensions = {
    AutoScalingGroupName = module.ec2_asg.autoscaling_group_name
  }

  alarm_description = "Scale Up alarm when CPU in autoscale group is above 80%"
  alarm_actions     = [aws_autoscaling_policy.ec2_autoscale_policy["jobshark_policy_scale_up"].arn]
}


resource "aws_cloudwatch_metric_alarm" "http5xx-scale-up-policy" {
  alarm_name          = "${var.env}-${var.short_region}  Autoscale HTTP5xx Scale Up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  depends_on = [
    module.ec2_asg,
  ]
  dimensions = {
    LoadBalancer = module.alb.lb_arn_suffix
  }

  alarm_description = "Scale Up when Target HTTP %xx responses are above 10 in a 1 minute period."
  alarm_actions     = [aws_autoscaling_policy.ec2_autoscale_policy["jobshark_policy_http5x_up"].arn]
}

resource "aws_cloudwatch_metric_alarm" "rc-target-scale-up" {
  alarm_name          = "${var.env}-${var.short_region} RequestCountPerTarget Scale Up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "82"
  depends_on = [
    module.ec2_asg,
  ]
  dimensions = {
    TargetGroup = element(module.alb.target_group_arn_suffixes, 0)
  }

  alarm_actions = [aws_autoscaling_policy.ec2_autoscale_policy["jobshark_policy_target_scale_up"].arn]
}

resource "aws_cloudwatch_metric_alarm" "rc-target-scale-down" {
  alarm_name          = "${var.env}-${var.short_region} RequestCountPerTarget Scale Down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCountPerTarget"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "15"
  depends_on = [
    module.ec2_asg,
  ]
  dimensions = {
    TargetGroup = element(module.alb.target_group_arn_suffixes, 0)
  }

  alarm_actions = [aws_autoscaling_policy.ec2_autoscale_policy["jobshark_policy_target_scale_down"].arn]
}
