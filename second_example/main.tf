provider "aws" {
	region = "us-east-1"
}

output "s3_bucket_arn" {
	description = "Outputs the Amazon Resource Name of s3 bucket"
	value = "${aws_s3_bucket.terraform_state.arn}"
}

#creates s3 bucket for us to store terraform state
resource "aws_s3_bucket" "terraform_state" {
	bucket = "jacob-terraform-state"

	versioning {
		enabled = true
	}

	lifecycle {
		prevent_destroy = true
	}
}

#creates dynamodb table for state locking
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
	name = "terraform-state-lock"
	hash_key = "LockID"
	read_capacity = 20
	write_capacity = 20

	attribute {
		name = "LockID"
		type = "S"
	}
	tags {
		name = "DynamoDB Terraform State Lock Table"
	}
}

#configures terraform to use the s3 bucket created
#this replaces the "terraform remote config" command used in the book
terraform {
	backend "s3" {
		bucket = "jacob-terraform-state"
		key = "global/s3/terraform.tfstate"
		region = "us-east-1"
		encrypt = "true"
		dynamodb_table = "terraform-state-lock"
	}
}
