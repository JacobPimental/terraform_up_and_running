#sets the provider for Terraform to use
provider "aws" {
  region = "us-east-1"
}

#defines a resource
resource "aws_instance" "example" {
  ami = "ami-40d28157"
  instance_type = "t2.micro"
  
  tags {
    Name = "terraform-example"
  }
}

/*Typical resouce type mainly follows the syntax
resource "PROVIDER_TYPE" "NAME" {
  [CONFIG]
}
*/
