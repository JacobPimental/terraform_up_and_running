#database password, the password can be stored as an environment variable that
#terraform can read and parse
#env variables use the syntax TF_VAR_foo
variable "db_password" {
	description = "The password for the database"
}

variable "cluster_name" {
	description = "The name of the database cluster"
}
