resource "aws_key_pair" "east_deployer" {
  key_name   = var.key_name
  public_key = var.key_deployed
}

resource "aws_key_pair" "west_deployer" {
  provider   = aws.west
  key_name   = var.key_name
  public_key = var.key_deployed
}