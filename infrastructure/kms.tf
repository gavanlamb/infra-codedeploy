resource "aws_kms_key" "codedeploy" {
  description = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation = true

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_kms_alias" "codedeploy" {
  name = "alias/expensely/codedeploy"
  target_key_id = aws_kms_key.codedeploy.key_id
}

resource "aws_iam_policy" "codedeploy_key" {
  description = "Policy for terraform state bucket"
  name = "codedeploy-key"
  path = "/codedeploy/"
  policy = data.aws_iam_policy_document.codedeploy_key.json
}
data "aws_iam_policy_document" "codedeploy_key" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:ListKeys"
    ]
    resources = [
      aws_kms_key.codedeploy.arn
    ]
  }
}
