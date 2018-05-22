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

#configures terraform to use the s3 bucket created
#this replaces the "terraform remote config" command used in the book
terraform {
	backend "s3" {
		bucket = "jacob-terraform-state"
		key = "global/s3/terraform.tfstate"
		region = "us-east-1"
		encrypt = "true"
	}
}
