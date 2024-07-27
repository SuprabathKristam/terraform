provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source = "./modules_ec2_instance"
  ami_value = "ami-04a81a99f5ec58529"
  aws_instance_type_vale = "t2.micro"
}