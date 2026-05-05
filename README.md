# AWS + Lambda Integration

## Descripción

Este proyecto implementa una arquitectura serverless en AWS para recibir, almacenar y procesar imágenes usando API Gateway, AWS Lambda, Amazon S3, Amazon SQS, IAM, VPC Endpoints y CloudWatch.

El flujo principal es:

Cliente → API Gateway → upload-lambda → S3 uploads/ → SQS → crop-lambda → S3 processed/

## Objetivo académico

El objetivo de la tarea es comprender, implementar y evidenciar el ciclo completo de vida de una infraestructura cloud usando Terraform:

1. Analizar el diagrama Mermaid proporcionado.
2. Implementar los recursos en AWS mediante Terraform.
3. Desplegar la arquitectura en una cuenta AWS.
4. Evidenciar los recursos desplegados mediante capturas.
5. Probar el flujo de subida y procesamiento de imágenes.
6. Destruir los recursos usando `terraform destroy`.
7. Documentar posibles errores durante la destrucción.

## Entornos soportados

La arquitectura está preparada para desplegarse en tres entornos:

- dev
- qa
- prod

Esto se controla mediante la variable:

```hcl
environment = "dev"
