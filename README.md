# AWS Lambda Integration - Image Processor

## Descripción del proyecto

En este proyecto se implemento una arquitectura serverless en AWS para recibir, almacenar y procesar imágenes utilizando Terraform como herramienta de Infraestructura como Código.

El sistema permite que un cliente envíe una imagen mediante una solicitud `POST /upload`. La imagen es recibida por API Gateway, procesada inicialmente por una función Lambda y almacenada en Amazon S3 dentro del prefijo `uploads/`. Luego, S3 genera un evento `ObjectCreated` que envía un mensaje a una cola SQS. Esta cola activa una segunda función Lambda encargada de procesar el archivo y guardar el resultado en el prefijo `processed/`.

El objetivo es comprender el ciclo completo de vida de una infraestructura en AWS: diseño, despliegue, prueba, monitoreo y destrucción de recursos mediante Terraform.

---

## Arquitectura general

Flujo principal:

```text
Cliente
  ↓
API Gateway HTTP API v2 - POST /upload
  ↓
upload-lambda
  ↓
Amazon S3 - uploads/
  ↓
Amazon SQS - Main Queue
  ↓
crop-lambda
  ↓
Amazon S3 - processed/
```

Componentes principales:

- API Gateway HTTP API v2
- AWS Lambda
- Amazon S3
- Amazon SQS
- Dead Letter Queue
- IAM Roles y Policies
- CloudWatch Logs
- CloudWatch Alarm
- Terraform AWS Provider v6

---

## Entornos soportados

La arquitectura está parametrizada para trabajar con tres entornos:

- `dev`
- `qa`
- `prod`

El entorno se define mediante la variable:

```hcl
environment = "dev"
```

Ejemplo de nombres generados:

```text
image-processor-dev-upload-lambda
image-processor-dev-crop-lambda
image-processor-dev-image-queue
image-processor-dev-image-dlq
image-processor-dev-images-ACCOUNT_ID
```

---

## Decisiones para reducción de costos

Algunos valores del diagrama original fueron ajustados para evitar costos innecesarios en un entorno académico.

| Configuración | Diagrama original | Implementación académica | Justificación |
|---|---:|---:|---|
| API Gateway throttling | 10,000 rps | 10 rps / burst 20 | Evitar consumo excesivo durante pruebas |
| S3 lifecycle uploads/ | 30 días | 1 día | Reducir almacenamiento innecesario |
| S3 lifecycle processed/ | 90 días | 3 días | Reducir almacenamiento innecesario |
| DLQ retention | 14 días | 4 días | Mantener análisis de errores sin extender costos |
| CloudWatch Logs | 14 días | 7 días | Suficiente para evidencia y depuración |
| NAT Gateway / VPC Endpoints | Incluidos en el diagrama | No desplegados en esta versión | Se omitieron para evitar costos por hora en laboratorio |

Estas modificaciones mantienen la lógica principal del sistema, pero adaptan a la infraestructura y de bajo costo.

---

## Requisitos previos

Antes de desplegar el proyecto se necesita:

- Cuenta AWS con permisos suficientes
- AWS CLI configurado
- Terraform instalado
- Git instalado
- Node.js instalado
- Debian en VirtualBox o entorno Linux equivalente

Verificar AWS CLI:

```bash
aws --version
```

Verificar identidad AWS:

```bash
aws sts get-caller-identity
```

Verificar Terraform:

```bash
terraform -version
```

---

## Estructura del proyecto

```text
aws-lambda-integration/
├── README.md
├── docs/
│   └── diagrama.mmd
├── lambda/
│   ├── upload/
│   │   └── index.mjs
│   └── crop/
│       └── index.mjs
└── terraform/
    ├── providers.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── main.tf
    ├── outputs.tf
    ├── s3.tf
    ├── sqs.tf
    ├── iam.tf
    ├── lambda.tf
    ├── apigateway.tf
    ├── events.tf
    ├── cloudwatch.tf
    └── .terraform.lock.hcl
```

---

## Despliegue con Terraform

Entrar a la carpeta Terraform:

```bash
cd terraform
```

Inicializar Terraform:

```bash
terraform init -upgrade
```

Formatear archivos:

```bash
terraform fmt
```

Validar configuración:

```bash
terraform validate
```

Revisar plan:

```bash
terraform plan
```

Aplicar infraestructura:

```bash
terraform apply
```

Confirmar escribiendo:

```text
yes
```

---

## Outputs importantes

Después del despliegue, se pueden ver los datos principales con:

```bash
terraform output
```

Para obtener solo el endpoint de subida:

```bash
terraform output upload_endpoint
```

También se puede guardar el endpoint en una variable de terminal:

```bash
UPLOAD_ENDPOINT=$(terraform output -raw upload_endpoint)
```

---

## Prueba funcional

Guardar el endpoint en una variable:

```bash
UPLOAD_ENDPOINT=$(terraform output -raw upload_endpoint)
```

Crear archivo de prueba:

```bash
nano test-upload.json
```

Contenido:

```json
{
  "filename": "prueba-dia3.png",
  "contentType": "image/png",
  "imageBase64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII="
}
```

Ejecutar solicitud:

```bash
curl -X POST "$UPLOAD_ENDPOINT" \
  -H "Content-Type: application/json" \
  --data @test-upload.json
```

Respuesta esperada:

```json
{
  "message": "Imagen subida correctamente.",
  "bucket": "image-processor-dev-images-ACCOUNT_ID",
  "key": "uploads/uuid-prueba-dia3.png"
}
```

Luego verificar en AWS:

```text
S3 → bucket del proyecto → uploads/
S3 → bucket del proyecto → processed/
```

Si aparece el archivo en `uploads/`, significa que funcionó la integración:

```text
API Gateway → upload-lambda → S3 uploads/
```

Si aparece un archivo en `processed/`, significa que funcionó la integración asíncrona:

```text
S3 ObjectCreated → SQS → crop-lambda → S3 processed/
```

---

## Monitoreo

Los logs se encuentran en CloudWatch:

```text
/aws/lambda/image-processor-dev-upload-lambda
/aws/lambda/image-processor-dev-crop-lambda
/aws/apigateway/image-processor-dev-upload-api
```

También se creó una alarma para la DLQ:

```text
image-processor-dev-dlq-messages-alarm
```

Esta alarma permite detectar si existen mensajes fallidos en la Dead Letter Queue.

---

## Destrucción de recursos

Al finalizar las pruebas, se debe ejecutar:

```bash
terraform destroy
```

Confirmar escribiendo:

```text
yes
```

Este paso es obligatorio para evitar costos innecesarios en AWS.

Después de destruir, se debe verificar manualmente que no queden activos recursos como:

- Buckets S3
- Lambdas
- SQS Queues
- API Gateway
- CloudWatch Alarms
- Log Groups
- IAM Roles

---

## Problemas encontrados durante el desarrollo

Durante el desarrollo se presentaron algunos problemas comunes:

1. **Credenciales expiradas**
   - Error: `ExpiredToken`
   - Causa: uso de credenciales temporales de AWS
   - Solución: renovar credenciales y validar con `aws sts get-caller-identity`

2. **Permisos insuficientes**
   - Error: `AccessDeniedException`
   - Causa: uso de rol `ReadOnlyAccess`
   - Solución: usar cuenta o rol con permisos de administrador para el laboratorio

3. **Log Groups ya existentes**
   - Error: `ResourceAlreadyExistsException`
   - Causa: AWS creó automáticamente los Log Groups de Lambda
   - Solución: importar los Log Groups a Terraform con `terraform import`

4. **Provider de Terraform no encontrado**
   - Error: provider no estaba en `.terraform/providers`
   - Causa: se eliminó la carpeta `.terraform`
   - Solución: ejecutar nuevamente `terraform init`

5. **Archivo pesado en GitHub**
   - Error: GitHub rechazó el push por archivo mayor a 100 MB
   - Causa: se intentó subir la carpeta `.terraform/`
   - Solución: crear `.gitignore`, excluir `.terraform/` y hacer un commit limpio

---

## Consideraciones de seguridad

- No se subieron credenciales AWS al repositorio.
- Los roles IAM siguen el principio de menor privilegio.
- El bucket S3 bloquea acceso público.
- Los permisos de S3 están separados por prefijo:
  - `upload-lambda` escribe en `uploads/`
  - `crop-lambda` lee de `uploads/` y escribe en `processed/`
- La cola SQS solo acepta mensajes desde el bucket S3 del proyecto.
- API Gateway tiene throttling reducido para controlar el consumo durante las pruebas.

---

## Estado del proyecto

La arquitectura implementa el flujo serverless principal solicitado en el laboratorio:

```text
API Gateway → Lambda → S3 → SQS → Lambda → S3
```

Algunos valores del diagrama original fueron ajustados para reducir costos en un entorno académico, manteniendo la lógica principal de la solución.
