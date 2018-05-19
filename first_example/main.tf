#sets the provider for Terraform to use
provider "aws" {
  region = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
  type = "string"
}

output "public_ip" {
	description = "Public IP of web server"
	value = "${aws_instance.example.public_ip}"
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
}

#defines a resource
resource "aws_instance" "example" {
  ami = "ami-40d28157"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p "${var.server_port}" &
    EOF
  
  tags {
    Name = "terraform-example"
  }
}

/*Typical resouce type mainly follows the syntax
resource "PROVIDER_TYPE" "NAME" {
  [CONFIG]
}
*/
