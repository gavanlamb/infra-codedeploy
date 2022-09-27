variable "azure_devops_projects_details" {
  type = list(object({
    project_name = string
    user_name = string
    assumeRoleUserArns = list(string)
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

resource "aws_iam_role" "codedeploy_user_access_time_preview" {
  provider = aws.time-preview
  assume_role_policy = data.aws_iam_policy_document.sts_assume_time_preview.json
}
data "aws_iam_policy_document" "sts_assume_time_preview"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.preview"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_time_preview" {
  provider = aws.time-preview
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_time_preview.name
}

resource "aws_iam_role" "codedeploy_user_access_time_production" {
  provider = aws.time-production
  assume_role_policy = data.aws_iam_policy_document.sts_assume_time_production.json
}
data "aws_iam_policy_document" "sts_assume_time_production"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.production"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_time_production" {
  provider = aws.time-production
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_time_production.name
}


resource "aws_iam_role" "codedeploy_user_access_shared_preview" {
  provider = aws.shared-preview
  assume_role_policy = data.aws_iam_policy_document.sts_assume_shared_preview.json
}
data "aws_iam_policy_document" "sts_assume_shared_preview"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.user.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.shared.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.preview"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_shared_preview" {
  provider = aws.shared-preview
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_shared_preview.name
}

resource "aws_iam_role" "codedeploy_user_access_shared_production" {
  provider = aws.shared-production
  assume_role_policy = data.aws_iam_policy_document.sts_assume_shared_production.json
}
data "aws_iam_policy_document" "sts_assume_shared_production"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.user.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.shared.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.production"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_shared_production" {
  provider = aws.shared-production
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_shared_production.name
}


resource "aws_iam_role" "codedeploy_user_access_networking_preview" {
  provider = aws.networking-preview
  assume_role_policy = data.aws_iam_policy_document.sts_assume_networking_preview.json
}
data "aws_iam_policy_document" "sts_assume_networking_preview"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.preview"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_networking_preview" {
  provider = aws.networking-preview
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_networking_preview.name
}

resource "aws_iam_role" "codedeploy_user_access_networking_production" {
  provider = aws.networking-production
  assume_role_policy = data.aws_iam_policy_document.sts_assume_networking_production.json
}
data "aws_iam_policy_document" "sts_assume_networking_production"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.production"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_networking_production" {
  provider = aws.networking-production
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_networking_production.name
}


resource "aws_iam_role" "codedeploy_user_access_user_preview" {
  provider = aws.user-preview
  assume_role_policy = data.aws_iam_policy_document.sts_assume_user_preview.json
}
data "aws_iam_policy_document" "sts_assume_user_preview"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.user.preview"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_user_preview" {
  provider = aws.user-preview
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_user_preview.name
}

resource "aws_iam_role" "codedeploy_user_access_user_production" {
  provider = aws.user-production
  assume_role_policy = data.aws_iam_policy_document.sts_assume_user_production.json
}
data "aws_iam_policy_document" "sts_assume_user_production"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.user.production"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_user_production" {
  provider = aws.user-production
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_user_production.name
}


resource "aws_iam_role" "codedeploy_user_access_platform_preview" {
  provider = aws.platform-preview
  assume_role_policy = data.aws_iam_policy_document.sts_assume_platform_preview.json
}
data "aws_iam_policy_document" "sts_assume_platform_preview"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.user.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.shared.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.preview",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.preview"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_platform_preview" {
  provider = aws.platform-preview
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_platform_preview.name
}

resource "aws_iam_role" "codedeploy_user_access_platform_production" {
  provider = aws.platform-production
  assume_role_policy = data.aws_iam_policy_document.sts_assume_platform_production.json
}
data "aws_iam_policy_document" "sts_assume_platform_production"{
  statement {
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = [
        "arn:aws:iam::258593516853:user/cicd/codedeploy.user.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.shared.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.time.production",
        "arn:aws:iam::258593516853:user/cicd/codedeploy.platform.production"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role_policy_attachment" "admin_access_platform_production" {
  provider = aws.platform-production
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.codedeploy_user_access_platform_production.name
}
