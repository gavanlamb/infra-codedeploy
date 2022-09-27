variable "bucket_name" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length."
  type        = string
}

resource "aws_s3_bucket" "codedeploy" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_public_access_block" "codedeploy" {
  bucket = aws_s3_bucket.codedeploy.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
resource "aws_s3_bucket_logging" "codedeploy" {
  bucket = aws_s3_bucket.codedeploy.id
  target_bucket = aws_s3_bucket.codedeploy.id
  target_prefix = "log/"
}
resource "aws_s3_bucket_acl" "codedeploy" {
  bucket = aws_s3_bucket.codedeploy.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "codedeploy" {
  bucket = aws_s3_bucket.codedeploy.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "codedeploy"{
  bucket = aws_s3_bucket.codedeploy.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.codedeploy.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "codedeploy_ssl" {
  bucket = aws_s3_bucket.codedeploy.id
  policy = data.aws_iam_policy_document.codedeploy.json

  depends_on = [aws_s3_bucket_public_access_block.codedeploy]
}
data "aws_iam_policy_document" "codedeploy_ssl" {
  statement {
    sid     = "AllowSSLRequestsOnly"
    actions = ["s3:*"]
    effect  = "Deny"
    principals {
      type = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.codedeploy.arn,
      "${aws_s3_bucket.codedeploy.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "codedeploy_bucket" {
  description = "Policy for terraform state bucket"
  name = "${var.bucket_name}-bucket"
  path = "/cicd/"
  policy = data.aws_iam_policy_document.codedeploy.json
}
data "aws_iam_policy_document" "codedeploy_bucket" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning"
    ]
    resources = [
      aws_s3_bucket.codedeploy.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListObject",
      "s3:PutObject"
    ]
    #tfsec:ignore:aws-iam-no-policy-wildcards
    resources = [
      "${aws_s3_bucket.codedeploy.arn}/*"
    ]
  }
}
