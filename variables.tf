variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "role_to_assume" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "Engram vpc"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  type = list(string)
  default = []
}

variable "private_cidr" {
  type = list(string)
  default = []
}

variable "multiple_zones" {
  type = bool
  default = false
}

variable "s3_bucket_name" {
  type = string
  default = "engram"
}

variable "db_name" {
  description = "Postgres DB Name"
  type        = string
}

variable "db_username" {
  description = "Postgres DB Username"
  type        = string
}

variable "db_password" {
  description = "Postgres DB Admin Password"
  type        = string
}

variable "api_port" {
  type = number
  default = 8055
}

variable "web_port" {
  type = number
  default = 3000
}

variable "backend_log_group_name" {
  type = string
  default = "/ecs/engram/backend"
}

variable "frontend_log_group_name" {
  type = string
  default = "/ecs/engram/frontend"
}

variable "ecs_container_number_backend" {
  type = number
  default = 1
}

variable "ecs_container_number_frontend" {
  type = number
  default = 1
}

variable "ecs_tf_backend_cpu" {
  type = number
  default = 1024
}

variable "ecs_tf_backend_ram" {
  type = number
  default = 2048
}

variable "ecs_tf_frontend_cpu" {
  type = number
  default = 512
}

variable "ecs_tf_frontend_ram" {
  type = number
  default = 1024
}

variable "ecs_container_backend_cpu" {
  type = number
  default = 1024
}

variable "ecs_container_backend_ram" {
  type = number
  default = 1024
}

variable "ecs_container_frontend_cpu" {
  type = number
  default = 512
}

variable "ecs_container_frontend_ram" {
  type = number
  default = 1024
}

variable "ecs_container_name_backend" {
  type = string
  default = "backend"
}

variable "ecs_container_name_frontend" {
  type = string
  default = "frontend"
}

variable "health_check_path_backend_tg" {
  type = string
  default = "/health"
}

variable "health_check_path_frontend_tg" {
  type = string
  default = "/health"
}

variable "domain_name_frontend" {
  type = string
  default = "scvengram.com"
}

variable "domain_name_backend" {
  type = string
  default = "admin.scvengram.com"
}

variable "use_tooling_ecr" {
  type = bool
  default = true
}

variable "specific_domain_cert_arn" {
  type = string
}

variable "wildcard_domain_cert_arn" {
  type = string
}