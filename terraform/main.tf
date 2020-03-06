locals {
  name_prefix         = "docker-cache-${var.stack_name}-${var.env}"
  path_prefix         = "/${var.aws_region}/${var.owner}/${var.stack_name}/${var.env}/"
}

provider "aws" {
  region = var.aws_region
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  # The latest version of Terragrunt (v0.19.0 and above) requires Terraform 0.12.0 or above.
  required_version = ">= 0.12.0"
}