resource "aws_apigatewayv2_api" "upload_api" {
  name          = "${local.name_prefix}-upload-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allowed_cors_origins
    allow_methods = var.allowed_cors_methods
    allow_headers = [
      "content-type",
      "authorization"
    ]
    max_age = 300
  }

  tags = {
    Name = "${local.name_prefix}-upload-api"
  }
}

resource "aws_apigatewayv2_integration" "upload_lambda" {
  api_id                 = aws_apigatewayv2_api.upload_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upload.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_upload" {
  api_id    = aws_apigatewayv2_api.upload_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.upload_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = var.api_throttle_rate_limit
    throttling_burst_limit = var.api_throttle_burst_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigateway.arn

    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  tags = {
    Name = "${local.name_prefix}-default-stage"
  }
}

resource "aws_lambda_permission" "allow_apigateway_invoke_upload" {
  statement_id  = "AllowAPIGatewayInvokeUploadLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.upload_api.execution_arn}/*/*"
}