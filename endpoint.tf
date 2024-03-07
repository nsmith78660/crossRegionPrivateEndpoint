resource "mongodbatlas_privatelink_endpoint" "east" {
  project_id    = var.project_id
  provider_name = "AWS"
  region        = "US_EAST_2"
}

resource "aws_vpc_endpoint" "east" {
  vpc_id             = aws_vpc.east.id
  service_name       = mongodbatlas_privatelink_endpoint.east.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.east_public1.id]
  security_group_ids = [aws_security_group.east_sg_ssh.id, aws_security_group.east_sg_mongod.id]
}

resource "mongodbatlas_privatelink_endpoint_service" "east" {
  project_id          = mongodbatlas_privatelink_endpoint.east.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.east.private_link_id
  endpoint_service_id = aws_vpc_endpoint.east.id
  provider_name       = "AWS"
}

resource "mongodbatlas_privatelink_endpoint" "west" {
  project_id    = var.project_id
  provider_name = "AWS"
  region        = "US_WEST_1"
}

resource "aws_vpc_endpoint" "west" {
  provider           = aws.west
  vpc_id             = aws_vpc.west.id
  service_name       = mongodbatlas_privatelink_endpoint.west.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.west-public.id]
  security_group_ids = [aws_security_group.west_sg_ssh.id, aws_security_group.west_sg_mongod.id]
}

resource "mongodbatlas_privatelink_endpoint_service" "west" {
  project_id          = mongodbatlas_privatelink_endpoint.west.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.west.private_link_id
  endpoint_service_id = aws_vpc_endpoint.west.id
  provider_name       = "AWS"

  depends_on = [mongodbatlas_privatelink_endpoint_service.east]
}