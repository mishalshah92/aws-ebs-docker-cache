variable "aws_region" {
  description = "AWS region, specify where to run ec2 instace and where are SSM keys."
}

# EC2 Launch template

variable "instance_type" {
  description = "Type of AWS instance to launch for caching."
  type        = string
  default     = "m5.large"
}

variable "docker_images" {
  description = "List of the docker images."
  type        = list(string)
  default     = []
}

# Lambda

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime."
  default     = "128"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  default     = "10"
}


# CloudWatch
variable "cron_schedule" {
  description = "A cron schdule for running lambda function."
}

# Tags

variable "owner" {
  description = "Your team's groupon E-Mail"
  type        = string
}

variable "stack_name" {
  description = "Name of your stack"
  type        = string
}

variable "env" {
  description = "Name of your environement"
  type        = string
}

variable "atom" {
  description = "Git SHA of the repository with deployment code"
  type        = string
}

variable "tool" {
  description = "Automation tool info"
  default     = "Managed by Terraform"
}