# Launch Template

output "ec2_lauch_template_arn" {
  description = "ARN of EC2 launch template."
  value       = aws_launch_template.docker_cache_instance_profile.arn
}

output "ec2_lauch_tempalte_name" {
  description = "Name of EC2 launch template."
  value       = aws_launch_template.docker_cache_instance_profile.name
}

output "ec2_lauch_tempalte_default_version" {
  description = "Name of EC2 launch template."
  value       = aws_launch_template.docker_cache_instance_profile.default_version
}

output "ec2_lauch_tempalte_latest_version" {
  description = "Name of EC2 launch template."
  value       = aws_launch_template.docker_cache_instance_profile.latest_version
}

# lambda
output "lambda_arn" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       = aws_lambda_function.docker_cache_lambda_function.arn
}

output "lambda_version" {
  description = "Latest published version of your Lambda Function."
  value       = aws_lambda_function.docker_cache_lambda_function.version
}

output "lambda_last_modified" {
  description = "The date this resource was last modified."
  value       = aws_lambda_function.docker_cache_lambda_function.last_modified
}

output "lambda_src_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file, provided either via filename or s3_* parameters."
  value       = aws_lambda_function.docker_cache_lambda_function.source_code_hash
}

# CloudWatch

output "cw_rule_arn" {
  description = "The Amazon Resource Name (ARN) of the rule."
  value       = aws_cloudwatch_event_rule.docker_cache_cloudwatch_event_rule.arn
}