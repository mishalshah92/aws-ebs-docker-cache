#########
### Cloud watch rule triggering lambda

resource "aws_cloudwatch_event_rule" "docker_cache_cloudwatch_event_rule" {
  name                = local.name_prefix
  description         = "Rule to trigger lambda function for caching docker images"
  schedule_expression = var.cron_schedule

  tags = {
    Name       = local.name_prefix
    Stack_name = var.stack_name
    Env        = var.env
    Owner      = var.owner
    Atom       = var.atom
    Tool       = var.tool
  }
}

resource "aws_cloudwatch_event_target" "docker_cache_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.docker_cache_cloudwatch_event_rule.name
  target_id = local.name_prefix
  arn       = aws_lambda_function.docker_cache_lambda_function.arn
}

resource "aws_lambda_permission" "docker_cache_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_cache_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.docker_cache_cloudwatch_event_rule.arn
}

#########
### Cloud watch rule triggering lambda to terminate instance

resource "aws_cloudwatch_event_rule" "docker_cache_instance_cloudwatch_event_rule" {
  name          = "docker-cache-instance-${var.stack_name}-${var.env}"
  description   = "Rule to trigger lambda function for terminating docker cache instance"
  event_pattern = data.template_file.docker_cache_snapshot_cw_event.rendered

  tags = {
    Name       = "docker-cache-instance-${var.stack_name}-${var.env}"
    Stack_name = var.stack_name
    Env        = var.env
    Owner      = var.owner
    Atom       = var.atom
    Tool       = var.tool
  }
}

resource "aws_cloudwatch_event_target" "docker_cache_instance_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.docker_cache_instance_cloudwatch_event_rule.name
  target_id = "docker-cache-instance-${var.stack_name}-${var.env}"
  arn       = aws_lambda_function.docker_cache_lambda_function.arn
}

resource "aws_lambda_permission" "docker_cache_instnace_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.docker_cache_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.docker_cache_instance_cloudwatch_event_rule.arn
}