provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  alias  = "west"
  region = "us-west-1"
}