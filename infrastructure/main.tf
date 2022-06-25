resource "aws_iam_role" "codedeploy" {
  name = var.code_deploy_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.code_deploy_bucket_name
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}
resource "aws_iam_policy" "bucket" {
  name = var.code_deploy_policy_name
  description = "Policy for uploading object to code deploy results bucket"
  policy = data.aws_iam_policy_document.bucket.json
}
data "aws_iam_policy_document" "bucket" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda" {
  name = "codedeploy-lambda"
  policy = data.aws_iam_policy_document.lambda.json
}
data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:PutLifecycleEventHookExecutionStatus"
    ]
    resources = [
      "arn:aws:codedeploy:*"
    ]
  }
}

resource "aws_lambda_function" "postman" {
  function_name = local.postman_name
  role = aws_iam_role.postman.arn
  description = "Postman tests"
  
  handler = "index.handler"
  runtime = "nodejs14.x"
  
  s3_bucket = "expensely-code-deploy-production"
  s3_key = "functions/postman.1.0.2599-1.zip"

  publish = true
  layers = ["arn:aws:lambda:${var.region}:901920570463:layer:aws-otel-nodejs-amd64-ver-1-2-0:1"]

  memory_size = 10240

  reserved_concurrent_executions = 1

  timeout = 900

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-handler"
    }
  }
}
resource "aws_cloudwatch_log_group" "postman" {
  name = "/aws/lambda/${aws_lambda_function.postman.function_name}"
  retention_in_days = 14
  kms_key_id = data.aws_kms_alias.cloudwatch.id
}
resource "aws_iam_role" "postman" {
  name = local.postman_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "postman_vpc" {
  role = aws_iam_role.postman.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "postman_codedeploy" {
  role = aws_iam_role.postman.name
  policy_arn = aws_iam_policy.lambda.arn
}
