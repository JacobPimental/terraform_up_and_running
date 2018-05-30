provider "aws" {
	region = "${var.aws_region}"
}

module "database_cluster" {
	source = "git::git@github.com:JacobPimental/terraform_up_and_running.git//modules/data-stores/mysql?ref=v0.0.12"

	cluster_name = "${var.cluster_name}"
	db_password = "${var.db_password}"
}

terraform {
	backend "s3" {
		bucket = "jacob-terraform-state"
		key = "stage/data-stores/mysql/terraform.tfstate"
		region = "us-east-1"
		encrypt = "true"
		dynamodb_table = "terraform-state-lock"
	}
}
