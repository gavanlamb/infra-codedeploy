variable "azure_devops_projects_details" {
  type = list(object({
    project_name = string
    user_name = string
    assumeRoleUserArns = list(string)
  }))
}
variable "sts_assume_role_details" {
  type = list(object({
    provider_name = string
    users = list(string)
  }))
}
data "azuredevops_project" "current" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}
  name = each.value.project_name
}
resource "azuredevops_variable_group" "credentials" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}
  project_id = data.azuredevops_project.current[each.key].id
  name = lower(each.value.user_name)
  description = "Environment variables for CodeDeploy"
  allow_access = true

  variable {
    name = "CODEDEPLOY_BACKEND_AWS_KEY_ID"
    secret_value = aws_iam_access_key.cicd[each.key].id
    is_secret = true
  }

  variable {
    name = "CODEDEPLOY_BACKEND_AWS_SECRET_KEY"
    secret_value = aws_iam_access_key.cicd[each.key].secret
    is_secret = true
  }

  variable {
    name = "CODEDEPLOY_BACKEND_AWS_REGION"
    value = var.region
  }

  variable {
    name = "CODEDEPLOY_BUCKET_NAME"
    value = aws_s3_bucket.codedeploy.id
  }
}

resource "aws_iam_user" "cicd" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}
  
  name = each.value.user_name
  path = "/cicd/"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_iam_access_key" "cicd" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}
  
  user = aws_iam_user.cicd[each.key].name
}
resource "aws_iam_user_policy_attachment" "bucket" {
  for_each = {for adpd in var.azure_devops_projects_details:  adpd.user_name => adpd}
  
  user = aws_iam_user.cicd[each.key].name
  policy_arn = aws_iam_policy.codedeploy_bucket.arn
}
resource "aws_iam_policy" "assume_policy" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}

  name = "${each.value.user_name}.assume_role"
  policy = data.aws_iam_policy_document.assume_policy[each.key].json
}
data "aws_iam_policy_document" "assume_policy" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    resources = each.value.assumeRoleUserArns
  }
}
resource "aws_iam_user_policy_attachment" "assume_policy" {
  for_each = {for adpd in var.azure_devops_projects_details: adpd.user_name => adpd}

  user = aws_iam_user.cicd[each.key].name
  policy_arn = aws_iam_policy.assume_policy[each.key].arn
}

resource "aws_iam_role" "codedeploy_user_access" {
  for_each = {for sard in var.sts_assume_role_details:  sard.provider_name => sard}
  
  provider = each.value.provider_name
  assume_role_policy = data.aws_iam_policy_document.sts_assume[each.key].json
}
data "aws_iam_policy_document" "sts_assume"{
  for_each = {for sard in var.sts_assume_role_details:  sard.provider_name => sard}
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = each.value.users
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access" {
  for_each = {for sard in var.azure_devops_projects_details:  sard.provider_name => sard}
  provider = each.value.provider_name
  
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access[each.key].name
}
