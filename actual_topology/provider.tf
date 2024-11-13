provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "memo-1x"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
