resource "aws_launch_configuration" "launch_images" {
  name                        = "launch-imgaes"
  image_id                    = data.aws_ami.ami_tf.id
  instance_type               = var.instance-type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tf_sg.id]
  user_data                   = file("run_images.sh")
  key_name                    = var.ssh-key
}

resource "aws_launch_configuration" "launch_videos" {
  name                        = "launch-videos"
  image_id                    = data.aws_ami.ami_tf.id
  instance_type               = var.instance-type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.tf_sg.id]
  user_data                   = file("run_videos.sh")
  key_name                    = var.ssh-key
}

resource "aws_lb" "tf_project_lb" {
  name               = "tf-project-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_sg.id]
  subnets            = [aws_subnet.tf_public.id, aws_subnet.tf_public2.id]
}

resource "aws_lb_target_group" "project_lb_target_images" {
  name     = "lb-target-images"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_aws_project_vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    port                = "traffic-port"
    path                = "/images/"
    matcher             = "200-320"
  }
}
resource "aws_lb_target_group" "project_lb_target_videos" {
  name     = "lb-target-videos"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_aws_project_vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    port                = "traffic-port"
    path                = "/videos/"
    matcher             = "200-320"
  }
}

resource "aws_lb_target_group" "project_lb_target_root" {
  name     = "lb-target-root"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_aws_project_vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    port                = "traffic-port"
    path                = "/"
    matcher             = "200-320"
  }
}

resource "aws_lb_listener" "tf_lb_listener" {
  load_balancer_arn = aws_lb.tf_project_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1 align='center'>You're in staging area, go to videos or images</h1>"
      status_code  = "200"

    }
  }
}
resource "aws_lb_listener_rule" "lb-listener_rule_images" {
  listener_arn = aws_lb_listener.tf_lb_listener.arn
  priority     = 55

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_lb_target_images.arn
  }

  condition {
    path_pattern {
      values = ["/images/*"]
    }
  }
}

resource "aws_lb_listener_rule" "lb-listener_rule_videos" {
  listener_arn = aws_lb_listener.tf_lb_listener.arn
  priority     = 45

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project_lb_target_videos.arn
  }

  condition {
    path_pattern {
      values = ["/videos/*"]
    }
  }
}

resource "aws_autoscaling_group" "autoscale_grp_image" {
  name                 = "autoScale-image"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  force_delete         = true
  launch_configuration = aws_launch_configuration.launch_images.name
  vpc_zone_identifier  = [aws_subnet.tf_public.id]
}

resource "aws_autoscaling_group" "autoscale_grp_video" {
  name                 = "autoScale-video"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  force_delete         = true
  launch_configuration = aws_launch_configuration.launch_videos.name
  vpc_zone_identifier  = [aws_subnet.tf_public2.id]
}


resource "aws_autoscaling_attachment" "as_attach_images" {
  autoscaling_group_name = aws_autoscaling_group.autoscale_grp_image.name
  alb_target_group_arn   = aws_lb_target_group.project_lb_target_images.arn
}
resource "aws_autoscaling_attachment" "as_attach_videos" {
  autoscaling_group_name = aws_autoscaling_group.autoscale_grp_video.name
  alb_target_group_arn   = aws_lb_target_group.project_lb_target_videos.arn
}

resource "aws_autoscaling_policy" "images_up" {
  name                   = "images-scale-up"
  autoscaling_group_name = aws_autoscaling_group.autoscale_grp_image.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}
resource "aws_autoscaling_policy" "images_down" {
  name                   = "images-scale-down"
  autoscaling_group_name = aws_autoscaling_group.autoscale_grp_image.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
}
resource "aws_autoscaling_policy" "videos_up" {
  name                   = "videos-scale-up"
  autoscaling_group_name = aws_autoscaling_group.autoscale_grp_video.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}
resource "aws_autoscaling_policy" "videos_down" {
  name                   = "videos-scale-down"
  autoscaling_group_name = aws_autoscaling_group.autoscale_grp_video.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
}

resource "aws_cloudwatch_metric_alarm" "videos_up" {
  alarm_name          = "videos-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscale_grp_video.name
  }

  alarm_description = "This metric will scale up videos servers when cpu > 50%"
  alarm_actions     = [aws_autoscaling_policy.videos_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "videos_down" {
  alarm_name          = "videos-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscale_grp_video.name
  }

  alarm_description = "This metric will scale down videos servers when cpu > 50%"
  alarm_actions     = [aws_autoscaling_policy.videos_down.arn]
}

resource "aws_cloudwatch_metric_alarm" "images_up" {
  alarm_name          = "images-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscale_grp_image.name
  }

  alarm_description = "This metric will scale up images servers when cpu > 50%"
  alarm_actions     = [aws_autoscaling_policy.images_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "images_down" {
  alarm_name          = "images-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscale_grp_image.name
  }

  alarm_description = "This metric will scale down images servers when cpu < 50%"
  alarm_actions     = [aws_autoscaling_policy.images_down.arn]
}