variable "env" {
  type = string
}

module "docker_cache_lambda" {
  source = "../terraform"

  stack_name    = "main"
  env           = var.env
  owner         = "test@gmail.com"
  aws_region    = "us-west-2"
  cron_schedule = "cron(0 * * * ? 2030)"
  atom          = "test"
}

output "launch_template" {
  value = module.docker_cache_lambda.ec2_lauch_template_arn
}
output "lambda_arn" {
  value = module.docker_cache_lambda.lambda_arn
}
output "cw_rule_arn" {
  value = module.docker_cache_lambda.cw_rule_arn
}