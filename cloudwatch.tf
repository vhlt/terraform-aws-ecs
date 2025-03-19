resource "aws_cloudwatch_log_group" "backend_log_group" {
  name = var.backend_log_group_name
}

resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name = var.frontend_log_group_name
}