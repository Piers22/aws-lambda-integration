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