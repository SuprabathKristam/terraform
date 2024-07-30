provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "example-keypair" {
  key_name = "suprabath-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example-subnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway" "example-igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "example-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example-igw.id
  }
}

resource "aws_route_table_association" "route-association" {
  subnet_id = aws_subnet.example-subnet.id
  route_table_id =aws_route_table.example-route.id
}

resource "aws_security_group" "example-sg" {
  name = "my-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example-instance" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example-keypair.key_name
  subnet_id     = aws_subnet.example-subnet.id
  vpc_security_group_ids = [aws_security_group.example-sg.id]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
  provisioner "file" {
    source      = "app.py"  # Replace with the path to your local file
    destination = "/home/ubuntu/app.py"  # Replace with the path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
}