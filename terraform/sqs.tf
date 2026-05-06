resource "aws_sqs_queue" "image_dlq" {
  name                      = "${local.name_prefix}-image-dlq"
  message_retention_seconds = var.sqs_dlq_message_retention_seconds

  tags = {
    Name = "${local.name_prefix}-image-dlq"
  }
}

resource "aws_sqs_queue" "image_queue" {
  name                       = "${local.name_prefix}-image-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.image_dlq.arn
    maxReceiveCount     = var.sqs_max_receive_count
  })

  tags = {
    Name = "${local.name_prefix}-image-queue"
  }
}

data "aws_iam_policy_document" "allow_s3_to_send_sqs_messages" {
  statement {
    sid    = "AllowS3SendMessageToImageQueue"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.image_queue.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.images.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "allow_s3_to_send_messages" {
  queue_url = aws_sqs_queue.image_queue.id
  policy    = data.aws_iam_policy_document.allow_s3_to_send_sqs_messages.json
}