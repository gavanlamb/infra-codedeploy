variable "environment" {
  type = string
  description = "Name of the environment the infrastructure is for."
}
variable "region" {
  type = string
  description = "Name of the AWS region to deploy resources to"
}
variable "build_identifier" {
  type = string
  description = "Build identifier"
}

locals {
  postman_name = "codedeploy-postman-${lower(var.environment)}"
}