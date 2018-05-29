provider "aws" {
	region = "us-east-1"
}

module "database_cluster" {
	source = "../../../modules/data-stores/mysql"

	cluster_name = "DatabaseProd"
	db_password = "${var.db_password}"
}

terraform {
	backend "s3" {
		bucket = "jacob-terraform-state"
		key = "prod/data-stores/mysql/terraform.tfstate"
		region = "us-east-1"
		encrypt = "true"
		dynamodb_table = "terraform-state-lock"
	}
}
