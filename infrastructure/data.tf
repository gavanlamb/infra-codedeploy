data "aws_caller_identity" "current" {}

data "aws_kms_alias" "cloudwatch" {
  name = "alias/expensely/production/cloudwatch"
}