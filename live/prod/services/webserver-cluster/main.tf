#define our provider as aws
provider "aws" {
	region = "us-east-1"
}

#uses the webserver cluster module from the modules folder
module "webserver_cluster" {
	source = "git::git@github.com:JacobPimental/terraform_up_and_running.git//modules/services/webserver-cluster?ref=v0.0.8" 

	enable_autoscaling = true
	cluster_name = "webservers-prod"
	db_remote_state_bucket = "jacob-terraform-state"
	db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
	instance_type = "t2.micro"
	min_size = 2
	max_size = 10
}



#------------------------------------------BACKEND-------------------------------------------


terraform {
	backend "s3" {
		bucket = "jacob-terraform-state"
		key = "prod/services/webserver-cluster/terraform.tfstate"
		region = "us-east-1"
		encrypt = "true"
		dynamodb_table = "terraform-state-lock"
	}
}
