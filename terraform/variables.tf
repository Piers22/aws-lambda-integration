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