resource "aws_vpc_peering_connection" "test" {
  peer_vpc_id = aws_vpc.west.id
  vpc_id      = aws_vpc.east.id
  peer_region = "us-west-1"
  peer_owner_id = var.aws_account_id

  tags = {
    Name = "VPC peering between east and west"
    owner = var.owner
    keep_until = var.keep_until
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.test.id
  auto_accept               = true
}