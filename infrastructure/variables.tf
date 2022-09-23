variable "environment" {
  type = string
  description = "Name of the environment the infrastructure is for."
}
variable "region" {
  type = string
  description = "Name of the AWS region to deploy resources to"
}
variable "shared_account_provider_role_arn" {
  type = string
}

locals {
  postman_name = "codedeploy-postman-${lower(var.environment)}"
}