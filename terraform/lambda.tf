data "archive_file" "upload_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/upload"
  output_path = "${path.module}/build/upload-lambda.zip"
}

data "archive_file" "crop_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/crop"
  output_path = "${path.module}/build/crop-lambda.zip"
}

resource "aws_lambda_function" "upload" {
  function_name = "${local.name_prefix}-upload-lambda"
  role          = aws_iam_role.upload_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  filename         = data.archive_file.upload_lambda_zip.output_path
  source_code_hash = data.archive_file.upload_lambda_zip.output_base64sha256

  memory_size = var.lambda_upload_memory
  timeout     = var.lambda_upload_timeout

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX    = var.upload_prefix
      MAX_FILE_SIZE_MB = tostring(var.max_file_size_mb)
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.upload_lambda_basic_logs,
    aws_iam_role_policy_attachment.upload_lambda_s3_policy_attachment,
    aws_cloudwatch_log_group.upload_lambda
  ]

  tags = {
    Name = "${local.name_prefix}-upload-lambda"
  }
}

resource "aws_lambda_function" "crop" {
  function_name = "${local.name_prefix}-crop-lambda"
  role          = aws_iam_role.crop_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  filename         = data.archive_file.crop_lambda_zip.output_path
  source_code_hash = data.archive_file.crop_lambda_zip.output_base64sha256

  memory_size = var.lambda_crop_memory
  timeout     = var.lambda_crop_timeout

  environment {
    variables = {
      S3_BUCKET        = aws_s3_bucket.images.bucket
      UPLOAD_PREFIX    = var.upload_prefix
      PROCESSED_PREFIX = var.processed_prefix
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.crop_lambda_basic_logs,
    aws_iam_role_policy_attachment.crop_lambda_policy_attachment,
    aws_cloudwatch_log_group.crop_lambda
  ]

  tags = {
    Name = "${local.name_prefix}-crop-lambda"
  }
}

