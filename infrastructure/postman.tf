resource "aws_iam_policy" "postman" {
  name = "codedeploy-lambda"
  policy = data.aws_iam_policy_document.postman.json
}
data "aws_iam_policy_document" "postman" {
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
  filename = "postman.zip"

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
data "aws_kms_alias" "cloudwatch" {
  provider = aws.shared
  name = "alias/expensely/cloudwatch"
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
resource "aws_iam_role_policy_attachment" "postman_bucket" {
  role = aws_iam_role.postman.name
  policy_arn = aws_iam_policy.bucket.arn
}

