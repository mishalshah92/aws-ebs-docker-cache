# IAM Resources

resource "aws_iam_policy" "docker_cache_ec2_iam_policy" {
  name   = "${local.name_prefix}-${var.aws_region}-ec2"
  path   = local.path_prefix
  policy = data.template_file.docker_cache_ec2_iam_policy_template.rendered
}

resource "aws_iam_role" "docker_cache_ec2_iam_role" {
  name = "${local.name_prefix}-${var.aws_region}-ec2"
  path = local.path_prefix

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "docker_cache_ec2_policy_attachment" {
  role       = aws_iam_role.docker_cache_ec2_iam_role.name
  policy_arn = aws_iam_policy.docker_cache_ec2_iam_policy.arn
}

resource "aws_iam_instance_profile" "docker_cache_ec2_instance_policy" {
  name = "${local.name_prefix}-${var.aws_region}"
  path = local.path_prefix
  role = aws_iam_role.docker_cache_ec2_iam_role.id
}

