data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid    = "AllowLambdaAssumeRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "upload_lambda_role" {
  name               = "${local.name_prefix}-upload-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name = "${local.name_prefix}-upload-lambda-role"
  }
}

resource "aws_iam_role" "crop_lambda_role" {
  name               = "${local.name_prefix}-crop-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name = "${local.name_prefix}-crop-lambda-role"
  }
}

resource "aws_iam_role_policy_attachment" "upload_lambda_basic_logs" {
  role       = aws_iam_role.upload_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "crop_lambda_basic_logs" {
  role       = aws_iam_role.crop_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "upload_lambda_s3_policy" {
  statement {
    sid    = "AllowUploadOnlyToUploadsPrefix"
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${var.upload_prefix}*"
    ]
  }
}

resource "aws_iam_policy" "upload_lambda_s3_policy" {
  name        = "${local.name_prefix}-upload-lambda-s3-policy"
  description = "Permite a upload-lambda escribir solo en el prefijo uploads/"
  policy      = data.aws_iam_policy_document.upload_lambda_s3_policy.json

  tags = {
    Name = "${local.name_prefix}-upload-lambda-s3-policy"
  }
}

resource "aws_iam_role_policy_attachment" "upload_lambda_s3_policy_attachment" {
  role       = aws_iam_role.upload_lambda_role.name
  policy_arn = aws_iam_policy.upload_lambda_s3_policy.arn
}

data "aws_iam_policy_document" "crop_lambda_policy" {
  statement {
    sid    = "AllowReadOriginalImages"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${var.upload_prefix}*"
    ]
  }

  statement {
    sid    = "AllowWriteProcessedImages"
    effect = "Allow"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${var.processed_prefix}*"
    ]
  }

  statement {
    sid    = "AllowConsumeImageQueue"
    effect = "Allow"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]

    resources = [
      aws_sqs_queue.image_queue.arn
    ]
  }
}

resource "aws_iam_policy" "crop_lambda_policy" {
  name        = "${local.name_prefix}-crop-lambda-policy"
  description = "Permite a crop-lambda leer uploads/, escribir processed/ y consumir SQS"
  policy      = data.aws_iam_policy_document.crop_lambda_policy.json

  tags = {
    Name = "${local.name_prefix}-crop-lambda-policy"
  }
}

resource "aws_iam_role_policy_attachment" "crop_lambda_policy_attachment" {
  role       = aws_iam_role.crop_lambda_role.name
  policy_arn = aws_iam_policy.crop_lambda_policy.arn
}