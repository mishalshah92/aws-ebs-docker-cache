#########
### Lambda resources

resource "aws_iam_policy" "docker_cache_iam_policy_lambda" {
  name   = "${local.name_prefix}-${var.aws_region}-lambda"
  path   = local.path_prefix
  policy = data.template_file.docker_cache_lambda_policy_template.rendered
}

resource "aws_iam_role" "iam_role_lambda" {
  name               = "${local.name_prefix}-${var.aws_region}-lambda"
  path               = local.path_prefix
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "docker_cache_iam_role_policy_attachment_lambda" {
  role       = aws_iam_role.iam_role_lambda.name
  policy_arn = aws_iam_policy.docker_cache_iam_policy_lambda.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "docker_cache_lambda_function" {
  description      = "Function to cache the docker iamges"
  function_name    = local.name_prefix
  filename         = "lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "lambda.lambda_handler"
  runtime          = "python3.6"
  role             = aws_iam_role.iam_role_lambda.arn
  memory_size      = var.memory_size
  timeout          = var.timeout

  environment {
    variables = {
      Owner      = var.owner
      Stack_name = var.stack_name
      Env        = var.env
      EC2_LC_ID  = aws_launch_template.docker_cache_instance_profile.id
      EC2_LC_VER = aws_launch_template.docker_cache_instance_profile.latest_version
    }
  }

  tags = {
    Stack_name = var.stack_name
    Env        = var.env
    Owner      = var.owner
    Atom       = var.atom
    Tool       = var.tool
  }
}