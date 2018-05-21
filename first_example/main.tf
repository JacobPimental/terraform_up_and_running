#sets the provider for Terraform to use
provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
  type = "string"
}

output "elb_dns" {
	description = "DNS of ELB"
	value = "${aws_elb.example.dns_name}"
}

#Creates security group that allows server to listen on port 8080
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port}" 
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
	lifecycle {
		create_before_destroy = true
	}
}

#Creates Security group for Elastic Load Balancer
resource "aws_security_group" "elb" {
	name = "terraform-example-elb"

	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

#defines a resource
resource "aws_launch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF
  
 lifecycle {
	 create_before_destroy = true
 }
}

#autoscaling group resource
resource "aws_autoscaling_group" "example" {
	launch_configuration = "${aws_launch_configuration.example.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	load_balancers = ["${aws_elb.example.name}"]
	health_check_type = "ELB"

	min_size = 2
	max_size = 10

	tag {
		key = "Name"
		value = "terraform-asg-example"
		propagate_at_launch = true
	}
}

#availability zone
data "aws_availability_zones" "all" {}

#elastic load-balancer for autoscaling group
resource "aws_elb" "example" {
	name = "terraform-asg-example"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	security_groups = ["${aws_security_group.elb.id}"]

	listener {
		lb_port = 80
		lb_protocol = "http"
		instance_port = "${var.server_port}"
		instance_protocol = "http"
	}

	health_check {
		healthy_threshold = 2
		unhealthy_threshold = 2
		timeout = 3
		interval = 30
		target = "HTTP:${var.server_port}/"
	}
}

/*Typical resouce type mainly follows the syntax
resource "PROVIDER_TYPE" "NAME" {
  [CONFIG]
}
*/
