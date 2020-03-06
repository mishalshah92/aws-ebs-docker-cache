data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnet_ids" "app_subnets" {
  vpc_id = data.aws_vpc.vpc.id
}

data "aws_ami" "ubuntu_ami" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "template_file" "docker_cache_ec2_user_data_template" {
  template = file("${path.module}/configs/ec2_user_data.sh")
  vars = {
    aws_region    = var.aws_region
    name          = local.name_prefix
    stack_name    = var.stack_name
    env           = var.env
    owner         = var.owner
    atom          = var.atom
    tool          = var.tool
    docker_images = join(" ", var.docker_images)
  }
}

data "template_file" "docker_cache_ec2_iam_policy_template" {
  template = file("${path.module}/configs/ec2_policy.json")

  vars = {
    aws_region  = var.aws_region
    aws_account = data.aws_caller_identity.current.account_id
  }
}

data "template_file" "docker_cache_lambda_policy_template" {
  template = file("${path.module}/configs/lambda_policy.json")

  vars = {
    aws_region     = var.aws_region
    aws_account_id = data.aws_caller_identity.current.account_id
  }
}

data "template_file" "docker_cache_snapshot_cw_event" {
  template = file("${path.module}/configs/docker_cache_snapshot_cw_event.json")
}