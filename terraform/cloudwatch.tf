resource "aws_cloudwatch_log_group" "upload_lambda" {
  name              = "/aws/lambda/${local.name_prefix}-upload-lambda"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    Name = "${local.name_prefix}-upload-lambda-logs"
  }
}

resource "aws_cloudwatch_log_group" "crop_lambda" {
  name              = "/aws/lambda/${local.name_prefix}-crop-lambda"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    Name = "${local.name_prefix}-crop-lambda-logs"
  }
}

resource "aws_cloudwatch_log_group" "apigateway" {
  name              = "/aws/apigateway/${local.name_prefix}-upload-api"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = {
    Name = "${local.name_prefix}-apigateway-logs"
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_messages_visible" {
  alarm_name          = "${local.name_prefix}-dlq-messages-alarm"
  alarm_description   = "Alarma cuando la DLQ tiene mensajes visibles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  period              = 60
  statistic           = "Sum"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"

  dimensions = {
    QueueName = aws_sqs_queue.image_dlq.name
  }

  actions_enabled = var.enable_dlq_alarm_actions

  tags = {
    Name = "${local.name_prefix}-dlq-messages-alarm"
  }
}