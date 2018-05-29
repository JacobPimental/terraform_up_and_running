#define our provider as aws
provider "aws" {
	region = "us-east-1"
}

#uses the webserver cluster module from the modules folder
module "webserver_cluster" {
	source = "../../../modules/services/webserver-cluster"

	cluster_name = "webservers-prod"
	db_remote_state_bucket = "jacob-terraform-state"
	db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"
	instance_type = "t2.micro"
	min_size = 2
	max_size = 10
}



#---------------------------------------------RESOURCES---------------------------------------------



resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
	scheduled_action_name = "scale-out-during-business-hours"
	min_size = 2
	max_size = 10
	desired_capacity = 10
	recurrence = "0 9 * * *"

	autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale_in_during_business_hours" {
	scheduled_action_name = "scale-in-during-business-hours"
	min_size = 2
	max_size = 10
	desired_capacity = 2
	recurrence = "0 17 * * *"

	autoscaling_group_name = "${module.webserver_cluster.asg_name}"
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
