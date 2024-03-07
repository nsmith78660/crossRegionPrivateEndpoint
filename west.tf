resource "aws_vpc" "west" {
  provider             = aws.west
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-main"
  }
}

resource "aws_subnet" "west_public" {
  provider   = aws.west
  vpc_id     = aws_vpc.west.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "tf-public1"
  }
}

resource "aws_subnet" "west_private" {
  provider   = aws.west
  vpc_id     = aws_vpc.west.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "tf-private1"
  }
}

resource "aws_security_group" "west_sg_ssh" {
  provider = aws.west
  tags = {
    Name = "SSH"
  }
  vpc_id = aws_vpc.west.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "west_sg_mongod" {
  provider = aws.west
  tags = {
    Name = "MONGOD"
  }
  vpc_id = aws_vpc.west.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 1024
    to_port     = 1073
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_instance" "west_instance" {
  provider      = aws.west
  ami           = "ami-05057ffd3a8e2ef62"
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    aws_security_group.west_sg_ssh.id,
    aws_security_group.west_sg_mongod.id
  ]
  subnet_id                   = aws_subnet.west_public.id
  key_name                    = var.key_name
  associate_public_ip_address = true
  user_data                   = file("./scripts/mongosh.yaml")

  tags = {
    Name = "tf-public1"
  }
}

resource "aws_network_interface" "west_netint" {
  provider        = aws.west
  subnet_id       = aws_subnet.west_public.id
  security_groups = [aws_security_group.west_sg_ssh.id]

  attachment {
    instance     = aws_instance.west_instance.id
    device_index = 1
  }

  tags = {
    Name = "tf-public1"
  }
}

resource "aws_internet_gateway" "west_gw" {
  provider = aws.west
  vpc_id   = aws_vpc.west.id

  tags = {
    Name = "tf-west-main"
  }
}

resource "aws_route_table" "west_rt" {
  provider = aws.west
  vpc_id   = aws_vpc.west.id

  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.west_gw.id
  }

  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.test.id
  }

  tags = {
    Name = "tf-west-rt"
  }
}

