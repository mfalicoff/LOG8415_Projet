# Fetch the latest Ubuntu 22.04 AMI from AWS
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "cluster-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "cluster-aws_key" {
  key_name = "ansible-ssh-key"
  public_key = tls_private_key.cluster-key.public_key_openssh
}

resource "aws_instance" "gatekeeper" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_security_group.gatekeeper.id]

  key_name = aws_key_pair.cluster-aws_key.key_name

  tags = {
    Name = "Gatekeeper"
  }
}

resource "aws_instance" "trusted_host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_security_group.trusted_host.id]

  key_name = aws_key_pair.cluster-aws_key.key_name

  tags = {
    Name = "Trusted Host"
  }
}

resource "aws_instance" "proxy" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_security_group.proxy.id]

  key_name = aws_key_pair.cluster-aws_key.key_name

  tags = {
    Name = "Proxy"
  }
}

resource "aws_instance" "cluster_manager" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cluster.id]

  key_name = aws_key_pair.cluster-aws_key.key_name

  tags = {
    Name            = "Cluster Manager"
  }
}

resource "aws_instance" "cluster_workers" {
  count = 3

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.cluster.id]

  key_name = aws_key_pair.cluster-aws_key.key_name

  tags = {
    Name            = "Cluster Worker ${count.index + 1}"
  }
}