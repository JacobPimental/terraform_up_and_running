output "s3_bucket_arn" {
	description = "Outputs the Amazon Resource Name of s3 bucket"
	value = "${aws_s3_bucket.terraform_state.arn}"
}
