#sets the provider for Terraform to use
provider "aws" {
  region = "us-east-1"
}

#Creates security group that allows server to listen on port 8080
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = 8080
    to_port = 8080
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
    nohup busybox httpd -f -p 8080 &
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
