resource "aws_vpc_peering_connection" "test" {
  peer_vpc_id = aws_vpc.west.id
  vpc_id      = aws_vpc.east.id
  peer_region = "us-west-1"

  tags = {
    Name = "VPC peering between east and west"
  }
}