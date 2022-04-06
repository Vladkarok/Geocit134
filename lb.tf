## Launch configuration with user data script to install and configure PostgreSQL
resource "aws_launch_configuration" "geo_web" {
  name_prefix                 = "geo-web-SNAPSHOT-1.0.5-"
  image_id                    = data.aws_ami.ubuntu_latest.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.allow_web.id]
  key_name                    = var.ssh_key_name
  enable_monitoring           = false
  associate_public_ip_address = true
  user_data = templatefile("./init.tftpl", {
    nexus_user     = "${var.nexus_user_login}"
    nexus_password = "${var.nexus_user_pass}"
    }
  )
  lifecycle {
    create_before_destroy = true
  }
}

## Define autoscaling group
resource "aws_autoscaling_group" "geo_web" {
  #  availability_zones        = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  name                      = "geo-web"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 90
  health_check_type         = "ELB"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  launch_configuration      = aws_launch_configuration.geo_web.name
  vpc_zone_identifier       = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  target_group_arns = [
    aws_lb_target_group.geo_web.arn
  ]
  lifecycle {
    ignore_changes = [
      desired_capacity,
      target_group_arns
    ]
  }
  tag {
    key                 = "Name"
    value               = "Ubuntu-Web"
    propagate_at_launch = true
  }
}

## Define autoscaling configuration policy
resource "aws_autoscaling_policy" "geo_web" {
  name                   = "geo-web"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.geo_web.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

## Instance Target Group
resource "aws_lb_target_group" "geo_web" {
  name        = "geo-web"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    path                = "/citizen/"
    interval            = 60
    port                = 8080
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}

## load balancer
resource "aws_lb" "geo_web" {
  name               = "geo-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_web.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
    Name        = "geo-web"
  }
}

## Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.geo_web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.geo_web.arn
  }
}

## Attach
# resource "aws_autoscaling_attachment" "asg_attachment_geo_web" {
#   autoscaling_group_name = aws_autoscaling_group.geo_web.id
#   lb_target_group_arn    = aws_lb_target_group.geo_web.arn
# }