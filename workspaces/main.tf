provider "aws" {
  region = "us-east-1"
}

variable "ami_value" {
  description = "value for the ami"
}

variable "instance_type" {
  description = "value for instance type"
  type = map(string)

  default = {
    "dev" = "t2.micro"
    "stag" = "t2.medium"
    "prod" = "t2.xlarge"
  }
}

module "ec2_instance" {
  source = "./ec2_module"
  ami_value = var.ami_value
  instance_type_value = lookup(var.instance_type,terraform.workspace,"t2.micro" )
}

# Here we are using lookup function to fetch values as part of syntax for lookup we need three values
#First is to lookup for a values (here is instance type)
#Second is Key string which here is terraform.workspace and here it will pick current work space (dev,stage,prod) that we are in
#Third is default if none of the value is matching it will go by default here it is t2.micro