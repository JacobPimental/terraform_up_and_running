#---------------------------------------------RESOURCES---------------------------------------------

#Creates security group that allows server to listen on port 8080
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "server_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.instance.id}"
  from_port         = "${var.server_port}"
  to_port           = "${var.server_port}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

#Creates Security group for Elastic Load Balancer
resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"

  lifecycle {
    create_before_destroy = true
  }
}

#rule to allow inbound http traffic
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

#rule to allow all outbound traffic
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

#defines a resource
resource "aws_launch_configuration" "example" {
  image_id        = "ami-40d28157"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data       = "${element( concat( data.template_file.user_data.*.rendered,
																  data.template_file.user_data_new.*.rendered), 0)}"

  lifecycle {
    create_before_destroy = true
  }
}

#autoscaling group resource
resource "aws_autoscaling_group" "example" {
  name                 = "${var.cluster_name}-${aws_launch_configuration.example.name}"
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  load_balancers       = ["${aws_elb.example.name}"]
  health_check_type    = "ELB"

  min_size         = "${var.min_size}"
  max_size         = "${var.max_size}"
  min_elb_capacity = "${var.min_size}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count                 = "${var.enable_autoscaling}"
  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
}

resource "aws_autoscaling_schedule" "scale_in_during_business_hours" {
  count                 = "${var.enable_autoscaling}"
  scheduled_action_name = "scale-in-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
}

#elastic load-balancer for autoscaling group
resource "aws_elb" "example" {
  name               = "${var.cluster_name}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count       = "${format("%.1s", var.instance_type) == "t" ? 1 : 0}"
  alarm_name  = "${var.cluster_name}-low-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}

#----------------------------------------------DATA--------------------------------------------------------

#availability zone
data "aws_availability_zones" "all" {}

#grabs address and port of mysql by calling the terraform remote state file
data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "${var.aws_region}"
  }
}

#data for our startup script read from a file
data "template_file" "user_data" {
  count    = "${1 - var.enable_new_user_data}"
  template = "${file("${path.module}/user-data.sh")}"

  vars = {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.db_address}"
    db_port     = "${data.terraform_remote_state.db.db_port}"
    server_text = "${var.server_text}"
  }
}

data "template_file" "user_data_new" {
  count    = "${var.enable_new_user_data}"
  template = "${file("${path.module}/user-data-new.sh")}"

  vars = {
    server_port = "${var.server_port}"
  }
}
