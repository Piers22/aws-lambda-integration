project_name = "image-processor"
environment  = "dev"
aws_region   = "us-east-1"

upload_prefix    = "uploads/"
processed_prefix = "processed/"

max_file_size_mb = 10

api_throttle_rate_limit  = 10
api_throttle_burst_limit = 20

lambda_upload_memory  = 256
lambda_crop_memory    = 512
lambda_upload_timeout = 30
lambda_crop_timeout   = 60

uploads_expiration_days   = 1
processed_expiration_days = 3
enable_s3_force_destroy   = true

sqs_visibility_timeout_seconds    = 360
sqs_message_retention_seconds     = 86400
sqs_dlq_message_retention_seconds = 345600
sqs_receive_wait_time_seconds     = 20
sqs_max_receive_count             = 3

allowed_cors_origins = ["*"]
allowed_cors_methods = ["POST", "OPTIONS"]

sqs_lambda_batch_size = 5

cloudwatch_log_retention_days = 7
enable_dlq_alarm_actions      = false