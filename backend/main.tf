provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "suprabath" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "suprabath-s3-state"
}


resource "aws_dynamodb_table" "terraform-lock" {
  name = "terraform-lock"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "5"
  }
}