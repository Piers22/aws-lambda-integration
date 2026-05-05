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