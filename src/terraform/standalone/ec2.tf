# Fetch the latest Ubuntu 22.04 AMI from AWS
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "standalone-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "standalone-aws_key" {
  key_name = "ansible-ssh-key"
  public_key = tls_private_key.standalone-key.public_key_openssh
}

resource "aws_instance" "standalone" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.standalone.id]

  key_name = aws_key_pair.standalone-aws_key.key_name

  tags = {
    Name            = "Standalone"
  }
}