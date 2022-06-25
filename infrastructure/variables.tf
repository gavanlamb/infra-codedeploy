variable "environment" {
  type = string
  description = "Name of the environment the infrastructure is for."
}
variable "region" {
  type = string
  description = "Name of the AWS region to deploy resources to"
}

variable "code_deploy_role_name" {
  type = string
  description = "Name of the role for CodeDeploy"
}
variable "code_deploy_policy_name" {
  type = string
  description = "Name of the policy for CodeDeploy"
}
variable "code_deploy_bucket_name" {
  type = string
  description = "Bucket name for CodeDeploy artifacts."
}

locals {
  postman_name = "codedeploy-postman${var.environment}"
}