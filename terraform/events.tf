resource "aws_s3_bucket_notification" "images_upload_notification" {
  bucket = aws_s3_bucket.images.id

  queue {
    queue_arn     = aws_sqs_queue.image_queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.upload_prefix
  }

  depends_on = [
    aws_sqs_queue_policy.allow_s3_to_send_messages
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_to_crop_lambda" {
  event_source_arn = aws_sqs_queue.image_queue.arn
  function_name    = aws_lambda_function.crop.arn

  batch_size                         = var.sqs_lambda_batch_size
  maximum_batching_window_in_seconds = 0
  enabled                            = true

  function_response_types = [
    "ReportBatchItemFailures"
  ]

  depends_on = [
    aws_iam_role_policy_attachment.crop_lambda_policy_attachment
  ]
}