resource "aws_vpc" "east" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "tf-east"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_subnet" "east_public1" {
  vpc_id     = aws_vpc.east.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "tf-east-public1"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_subnet" "east_private1" {
  vpc_id     = aws_vpc.east.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "tf-east-private1"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_security_group" "east_sg_ssh" {
  tags = {
    Name = "SSH"
  }
  vpc_id = aws_vpc.east.id
  ingress {
    cidr_blocks = var.vpn_blocks
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

resource "aws_security_group" "east_sg_mongod" {
  tags = {
    Name = "MONGOD-PE"
  }
  vpc_id = aws_vpc.east.id
  ingress {
    cidr_blocks = [aws_vpc.east.cidr_block, aws_vpc.west.cidr_block]
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

resource "aws_instance" "east_public" {
  ami                         = "ami-02ca28e7c7b8f8be1"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.east_public1.id
  key_name                    = var.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.east_sg_ssh.id,
    aws_security_group.east_sg_mongod.id
  ]
  # Add mongosh to the instance using cloud-init
  user_data = file("./scripts/mongosh.yaml")

  tags = {
    Name = "tf-east-public"
    owner = var.owner
    keep_until = var.keep_until
  }
}


resource "aws_network_interface" "east_net_int" {
  subnet_id       = aws_subnet.east_public1.id
  security_groups = [aws_security_group.east_sg_ssh.id]

  attachment {
    instance     = aws_instance.east_public.id
    device_index = 1
  }

  tags = {
    Name = "tf-east-public"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_internet_gateway" "east" {
  vpc_id = aws_vpc.east.id

  tags = {
    Name = "tf-east-main"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_route_table" "east_rt" {
  vpc_id = aws_vpc.east.id

  route {
    cidr_block = aws_vpc.east.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.east.id
  }

  route {
    cidr_block                = aws_vpc.west.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.test.id
  }

  tags = {
    Name = "tf-east-rt"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_route_table_association" "east_pub_rt_assc" {
  subnet_id      = aws_subnet.east_public1.id
  route_table_id = aws_route_table.east_rt.id
}

resource "aws_route_table_association" "east_pri_rt_assc" {
  subnet_id      = aws_subnet.east_private1.id
  route_table_id = aws_route_table.east_rt.id
}