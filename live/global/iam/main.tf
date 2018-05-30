provider "aws"
{
	region = "us-east-1"
}



#---------------------------------------------RESOURCES---------------------------------------------


#creates an AWS IAM user called neo
resource "aws_iam_user" "example" {
	count = 3 #how many times we want to run this
	name = "${element(var.user_names, count.index)}"
}


#creates policy for IAM users by calling the policy document
resource "aws_iam_policy" "ec2_read_only" {
	name = "ec2-read-only"
	policy = "${data.aws_iam_policy_document.ec2_read_only.json}"
}


#attaches the policy to each IAM user
resource "aws_iam_user_policy_attachment" "ec2_access" {
	count = "${length(var.user_names)}"
	user = "${element(aws_iam_user.example.*.name, count.index)}"
	policy_arn = "${aws_iam_policy.ec2_read_only.arn}"
}


resource "aws_iam_policy" "cloudwatch_read_only" {
	name = "cloudwatch-read-only"
	policy = "${data.aws_iam_policy_document.cloudwatch_read_only.json}"
}


resource "aws_iam_policy" "cloudwatch_full_access" {
	name = "cloudwatch-full-access"
	policy = "${data.aws_iam_policy_document.cloudwatch_full_access.json}"
}


resource "aws_iam_user_policy_attachment" "neo_cloudwatch_full_access" {
	count = "${var.give_neo_cloudwatch_full_access}"
	user = "${aws_iam_user.example.0.name}"
	policy_arn = "${aws_iam_policy.cloudwatch_full_access.arn}"
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_read_only" {
	count = "${1 - var.give_neo_cloudwatch_full_access}"
	user = "${aws_iam_user.example.0.name}"
	policy_arn = "${aws_iam_policy.cloudwatch_read_only.arn}"
}



#---------------------------------------------DATA---------------------------------------------



#IAM policy data
data "aws_iam_policy_document" "ec2_read_only" {
	statement {
		effect = "Allow"
		actions = ["ec2:Describe*"]
		resources = ["*"]
	}
}


data "aws_iam_policy_document" "cloudwatch_read_only" {
	statement {
		effect = "Allow"
		actions = ["cloudwatch:Describe*", "cloudwatch:Get*", "cloudwatch:List*"]
		resources = ["*"]
	}
}


data "aws_iam_policy_document" "cloudwatch_full_access" {
	statement{ 
		effect = "Allow"
		actions = ["cloudwatch:*"]
		resources = ["*"]
	}
}



#---------------------------------------------BACKEND---------------------------------------------



terraform {
	backend "s3" {
		bucket = "jacob-terraform-state"
		key = "global/iam/terraform.tfstate"
		region = "us-east-1"
		encrypt = "true"
		dynamodb_table = "terraform-state-lock"
	}
}
