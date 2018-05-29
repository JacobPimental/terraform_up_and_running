variable "cluster_name" {
	description = "The name to use for all cluster resources"
}

variable "db_remote_state_bucket" {
	description = "The name of the s3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
	description = "The path for the database's remote state in s3"
}

variable "instance_type" {
	description = "THe type of EC2 instance we want to use"
}

variable "min_size" {
	description = "The minimum amount of servers we wish to have"
}

variable "max_size" {
	description = "THe maximum amount of servers we wish to have"
}

variable "enable_autoscaling" {
	description = "If set to true, enable auto scaling"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
  type = "string"
}
