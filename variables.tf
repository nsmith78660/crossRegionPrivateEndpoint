variable "project_id" {
  description = "The project ID to use"
  type        = string
}

variable "aws_account_id" {
  description = "The ID of the AWS account"
  type        = string
}

variable "instance_size" {
  description = "The size of the instance"
  type = string
}

variable "key_name" {
  description = "AWS key name"
  type = string
}

variable "key_deployed" {
  description = "SSH Key"
  type = string
}

variable "owner" {
  description = "owner"
  type = string
}

variable "keep_until" {
  description = "keep resources until"
  type = string
}

variable "vpn_blocks" {
  description = "IP blocks for VPN"
  type = list(string)
}