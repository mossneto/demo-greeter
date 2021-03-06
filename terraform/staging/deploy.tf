provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_security_group" "greeter" {
  name = "greeter-security"
  description = "Allow SSH"

  # TCP access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "greeter-lb" {
  name            = "greeter-lb"
  security_groups = [ "${aws_security_group.greeter.id}" ]
  availability_zones = [ "us-east-1a", "us-east-1b" ]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }
}

resource "aws_key_pair" "greeter" {
  key_name      = "${var.aws_key_pair_name}"
  public_key    = "${var.aws_public_key}"
}

resource "aws_launch_configuration" "greeter-lc" {
  connection {
    type           = "ssh"
    user           = "ubuntu"
    private_key    = "${file("${var.aws_private_key}")}"
    agent          = false
    timeout        = "2m"
  }

  name_prefix                      = "greeter-lc-"
  image_id                         = "${var.aws_ami}"
  instance_type                    = "${var.aws_instance_type}"

  key_name                         = "${var.aws_key_pair_name}"

  security_groups  = [ "${aws_security_group.greeter.id}" ]

  lifecycle {
    create_before_destroy = true
  }

  provisioner "remote-exec" {
    inline = [
      "mvn dependency:get -DremoteRepositories=${var.greeter_repo_id}::::${var.greeter_repo_url} -DgroupId=com.mossneto -DartifactId=greeter -Dversion=${var.greeter_version} -Dtransitive=false -Ddest=.",
      "java -jar com.mossneto.greeter-${var.greeter_version}.jar"
    ]
  }
}

resource "aws_autoscaling_group" "greeters" {
  availability_zones        = [ "us-east-1a", "us-east-1b" ]
  name                      = "greeters-asg"
  max_size                  = "5"
  min_size                  = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.greeter-lc.name}"
  load_balancers            = [ "${aws_elb.greeter-lb.id}" ]

  tag {
    key                     = "Name"
    value                   = "Greeter Instances"
    propagate_at_launch     = true
  }
}

resource "aws_autoscaling_policy" "greeters-scale-up" {
  name                      = "greeters-scale-up"
  scaling_adjustment        = 1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 120
  autoscaling_group_name    = "${aws_autoscaling_group.greeters.name}"
}

resource "aws_autoscaling_policy" "greeters-scale-down" {
  name                      = "greeters-scale-down"
  scaling_adjustment        = -1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 300
  autoscaling_group_name    = "${aws_autoscaling_group.greeters.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name                = "cpu-high"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "180"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_actions             = [ "${aws_autoscaling_policy.greeters-scale-up.arn}" ]
  dimensions {
    AutoScalingGroupName    = "${aws_autoscaling_group.greeters.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name                = "cpu-low"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "50"
  alarm_actions             = [ "${aws_autoscaling_policy.greeters-scale-down.arn}" ]
  dimensions {
    AutoScalingGroupName    = "${aws_autoscaling_group.greeters.name}"
  }
}
