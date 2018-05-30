#define our provider as aws
provider "aws" {
  region = "${var.aws_region}"
}

#uses the webserver cluster module from the modules folder
module "webserver_cluster" {
  source = "git::git@github.com:JacobPimental/terraform_up_and_running.git//modules/services/webserver-cluster?ref=v0.0.13"

  ami                    = "${data.aws_ami.ubuntu.id}"
  enable_autoscaling     = true
  enable_new_user_data   = false
  server_text            = "Prod Server!"
  aws_region             = "${var.aws_region}"
  cluster_name           = "${var.cluster_name}"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key    = "${var.db_remote_state_key}"
  instance_type          = "t2.micro"
  min_size               = 2
  max_size               = 10
}

#---------------------------------------------BACKEND---------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
}

#------------------------------------------BACKEND-------------------------------------------

terraform {
  backend "s3" {
    bucket         = "jacob-terraform-state"
    key            = "prod/services/webserver-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "terraform-state-lock"
  }
}
