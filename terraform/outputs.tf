output "project_environment" {
  description = "Entorno actual del despliegue"
  value       = var.environment
}

output "aws_region" {
  description = "Región AWS usada"
  value       = var.aws_region
}

output "name_prefix" {
  description = "Prefijo usado para nombrar recursos"
  value       = local.name_prefix
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3 de imágenes"
  value       = aws_s3_bucket.images.bucket
}

output "s3_upload_prefix" {
  description = "Prefijo para imágenes originales"
  value       = var.upload_prefix
}

output "s3_processed_prefix" {
  description = "Prefijo para imágenes procesadas"
  value       = var.processed_prefix
}

output "sqs_queue_name" {
  description = "Nombre de la cola principal SQS"
  value       = aws_sqs_queue.image_queue.name
}

output "sqs_queue_url" {
  description = "URL de la cola principal SQS"
  value       = aws_sqs_queue.image_queue.url
}

output "sqs_dlq_name" {
  description = "Nombre de la Dead Letter Queue"
  value       = aws_sqs_queue.image_dlq.name
}

output "sqs_dlq_url" {
  description = "URL de la Dead Letter Queue"
  value       = aws_sqs_queue.image_dlq.url
}

output "upload_lambda_role_name" {
  description = "Nombre del rol IAM de upload-lambda"
  value       = aws_iam_role.upload_lambda_role.name
}

output "crop_lambda_role_name" {
  description = "Nombre del rol IAM de crop-lambda"
  value       = aws_iam_role.crop_lambda_role.name
}

output "upload_lambda_policy_name" {
  description = "Nombre de la política IAM de upload-lambda"
  value       = aws_iam_policy.upload_lambda_s3_policy.name
}

output "crop_lambda_policy_name" {
  description = "Nombre de la política IAM de crop-lambda"
  value       = aws_iam_policy.crop_lambda_policy.name
}

output "upload_lambda_name" {
  description = "Nombre de la Lambda encargada de subir imágenes"
  value       = aws_lambda_function.upload.function_name
}

output "upload_lambda_arn" {
  description = "ARN de upload-lambda"
  value       = aws_lambda_function.upload.arn
}

output "crop_lambda_name" {
  description = "Nombre de la Lambda encargada de procesar imágenes"
  value       = aws_lambda_function.crop.function_name
}

output "crop_lambda_arn" {
  description = "ARN de crop-lambda"
  value       = aws_lambda_function.crop.arn
}

output "api_gateway_name" {
  description = "Nombre de API Gateway HTTP API"
  value       = aws_apigatewayv2_api.upload_api.name
}

output "api_gateway_endpoint" {
  description = "Endpoint base de API Gateway"
  value       = aws_apigatewayv2_api.upload_api.api_endpoint
}

output "upload_endpoint" {
  description = "Endpoint completo para subir imágenes"
  value       = "${aws_apigatewayv2_api.upload_api.api_endpoint}/upload"
}

output "s3_notification_id" {
  description = "ID de la configuración de notificación S3 hacia SQS"
  value       = aws_s3_bucket_notification.images_upload_notification.id
}

output "sqs_to_lambda_mapping_uuid" {
  description = "UUID del event source mapping entre SQS y crop-lambda"
  value       = aws_lambda_event_source_mapping.sqs_to_crop_lambda.uuid
}

output "upload_lambda_log_group" {
  description = "Log group de upload-lambda"
  value       = aws_cloudwatch_log_group.upload_lambda.name
}

output "crop_lambda_log_group" {
  description = "Log group de crop-lambda"
  value       = aws_cloudwatch_log_group.crop_lambda.name
}

output "apigateway_log_group" {
  description = "Log group de API Gateway"
  value       = aws_cloudwatch_log_group.apigateway.name
}

output "dlq_alarm_name" {
  description = "Nombre de la alarma CloudWatch para la DLQ"
  value       = aws_cloudwatch_metric_alarm.dlq_messages_visible.alarm_name
}