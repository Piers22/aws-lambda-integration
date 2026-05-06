variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue: dev, qa o prod"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "El environment debe ser dev, qa o prod."
  }
}

variable "aws_region" {
  description = "Región AWS donde se desplegará la infraestructura"
  type        = string
}

variable "upload_prefix" {
  description = "Prefijo S3 para imágenes originales"
  type        = string
  default     = "uploads/"
}

variable "processed_prefix" {
  description = "Prefijo S3 para imágenes procesadas"
  type        = string
  default     = "processed/"
}

variable "max_file_size_mb" {
  description = "Tamaño máximo permitido para subir imágenes"
  type        = number
  default     = 10
}

variable "api_throttle_rate_limit" {
  description = "Límite de solicitudes por segundo para API Gateway"
  type        = number
  default     = 10
}

variable "api_throttle_burst_limit" {
  description = "Cantidad máxima de solicitudes permitidas en ráfaga para API Gateway"
  type        = number
  default     = 20
}

variable "lambda_upload_memory" {
  description = "Memoria para upload-lambda"
  type        = number
  default     = 256
}

variable "lambda_crop_memory" {
  description = "Memoria para crop-lambda"
  type        = number
  default     = 512
}

variable "lambda_upload_timeout" {
  description = "Timeout de upload-lambda en segundos"
  type        = number
  default     = 30
}

variable "lambda_crop_timeout" {
  description = "Timeout de crop-lambda en segundos"
  type        = number
  default     = 60
}

variable "uploads_expiration_days" {
  description = "Días para expirar imágenes originales en uploads/"
  type        = number
  default     = 1
}

variable "processed_expiration_days" {
  description = "Días para expirar imágenes procesadas en processed/"
  type        = number
  default     = 3
}

variable "enable_s3_force_destroy" {
  description = "Permite destruir el bucket aunque tenga objetos dentro. Útil para laboratorio académico."
  type        = bool
  default     = true
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tiempo en segundos durante el cual un mensaje queda invisible mientras Lambda lo procesa"
  type        = number
  default     = 360
}

variable "sqs_message_retention_seconds" {
  description = "Tiempo de retención de mensajes en la cola principal"
  type        = number
  default     = 86400
}

variable "sqs_dlq_message_retention_seconds" {
  description = "Tiempo de retención de mensajes en la DLQ"
  type        = number
  default     = 345600
}

variable "sqs_receive_wait_time_seconds" {
  description = "Tiempo de long polling para reducir respuestas vacías"
  type        = number
  default     = 20
}

variable "sqs_max_receive_count" {
  description = "Número máximo de intentos fallidos antes de enviar el mensaje a la DLQ"
  type        = number
  default     = 3
}

variable "allowed_cors_origins" {
  description = "Orígenes permitidos para CORS"
  type        = list(string)
  default     = ["*"]
}

variable "allowed_cors_methods" {
  description = "Métodos HTTP permitidos por CORS"
  type        = list(string)
  default     = ["POST", "OPTIONS"]
}

variable "sqs_lambda_batch_size" {
  description = "Cantidad de mensajes que Lambda procesa por lote desde SQS"
  type        = number
  default     = 5
}

variable "cloudwatch_log_retention_days" {
  description = "Días de retención para logs de CloudWatch"
  type        = number
  default     = 7
}

variable "enable_dlq_alarm_actions" {
  description = "Habilita acciones de alarma para la DLQ. En laboratorio se deja false para evitar configurar SNS."
  type        = bool
  default     = false
}