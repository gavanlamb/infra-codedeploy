variable "azure_devops_projects_details" {
  type = list(object({
    provider_name = string
    assumeRoleUserArns = list(string)
  }))
}

resource "aws_iam_user" "cicd" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}
  
  name = "codedeploy.${each.value.provider_name}"
  path = "/cicd/"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_iam_access_key" "cicd" {
  for_each = {for adad in var.azure_devops_projects_details: adad.provider_name => adad}
  
  user = aws_iam_user.cicd[each.key].name
}
resource "aws_iam_user_policy_attachment" "bucket" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}
  
  user = aws_iam_user.cicd[each.key].name
  policy_arn = aws_iam_policy.codedeploy_bucket.arn
}
resource "aws_iam_user_policy_attachment" "assume_policy" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}

  user = aws_iam_user.cicd[each.key].name
  policy_arn = aws_iam_policy.assume_policy[each.key].arn
}

resource "aws_iam_policy" "assume_policy" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}

  provider = "aws.${each.value.provider_name}"

  name = "${each.value.provider_name}.assume_role"
  policy = data.aws_iam_policy_document.assume_policy[each.key].json
}
data "aws_iam_policy_document" "assume_policy" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    resources = each.value.assumeRoleUserArns
  }
}

// TODO add the trust relationship role from the account
resource "aws_iam_role" "admin_access" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}
  provider = "aws.${each.value.provider_name}"
  assume_role_policy = aws_iam_role_policy.a
}
resource "aws_iam_role_policy" "sts_assume" {
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}
  provider = "aws.${each.value.provider_name}"
  policy = ""
  role = ""
}
data "aws_iam_policy_document" "sts_assume"{
  for_each = {for adad in var.azure_devops_projects_details:  adad.provider_name => adad}
  provider = "aws.${each.value.provider_name}"
  statement {
    sid = ""
    effect = "Allow"
    principals {
      type = "aws"
      identifiers = 
    }
    actions = [
    ]
  }
}
resource "policy_attachment" "" {}
resource "aws_iam_role_policy_attachment" "" {
  target_group_arn = ""
  target_id        = ""
  policy_arn       = ""
  role             = ""
}
// admin access
