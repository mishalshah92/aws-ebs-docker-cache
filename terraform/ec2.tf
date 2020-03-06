# EC2 Resources

resource "aws_security_group" "docker_cache_security_group" {
  name   = local.name_prefix
  vpc_id = data.aws_vpc.vpc.id

  tags = {
    Name       = local.name_prefix
    Stack_name = var.stack_name
    Env        = var.env
    Owner      = var.owner
    Tool       = var.tool
  }

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"

    cidr_blocks = [
      local.ingress_cidr_blocks,
    ]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_launch_template" "docker_cache_instance_profile" {
  name        = local.name_prefix
  description = "Docker cache ${var.stack_name} ${var.env} luanch template"

  image_id                             = data.aws_ami.ubuntu_ami.id
  instance_type                        = var.instance_type
  instance_initiated_shutdown_behavior = "terminate"
  iam_instance_profile {
    name = aws_iam_instance_profile.docker_cache_ec2_instance_policy.name
  }

  network_interfaces {
    description                 = "Docker cache ${var.stack_name} ${var.env} nw interface "
    associate_public_ip_address = false
    delete_on_termination       = true
    subnet_id                   = element(tolist(data.aws_subnet_ids.app_subnets.ids), 0)
    security_groups             = [aws_security_group.docker_cache_security_group.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 35
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = 100
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name       = "${local.name_prefix}-${var.atom}"
      Stack_name = var.stack_name
      Env        = var.env
      Owner      = var.owner
      Atom       = var.atom
      Tool       = var.tool
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name       = "${local.name_prefix}-${var.atom}"
      Stack_name = var.stack_name
      Env        = var.env
      Owner      = var.owner
      Atom       = var.atom
      Tool       = var.tool
    }
  }

  tags = {
    Stack_name = var.stack_name
    Env        = var.env
    Owner      = var.owner
    Atom       = var.atom
    Tool       = var.tool
  }

  user_data = base64encode(data.template_file.docker_cache_ec2_user_data_template.rendered)
}