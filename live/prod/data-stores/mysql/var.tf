variable "db_password" {
	description = "Database password used to pass into the database module"
}

variable "aws_region" {
	description = "The region for AWS"
	default = "us-east-1"
}

variable "cluster_name" {
	description = "THe name for the cluster"
	default = "DatabaseProd"
}
