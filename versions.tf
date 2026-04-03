terraform {
  # major version of Terraform to use
  required_version = ">=1.1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # minimum version of the AWS provider to use
      version = "~> 6.0"
    }

  }
}