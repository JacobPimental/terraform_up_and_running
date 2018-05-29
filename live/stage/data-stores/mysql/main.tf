provider "aws" {
	region = "us-east-1"
}

module "database_cluster" {
	source = "git::git@github.com:JacobPimental/terraform_up_and_running.git//modules/data-stores/mysql?ref=v0.0.1"

	cluster_name = "DatabaseStage"
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
