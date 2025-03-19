output "postgres_endpoint" {
  value       = aws_db_instance.postgresdb.endpoint
  description = "Connection endpoint for PostGresql"
}

output "alb_dns_name" {
  value = aws_lb.engram_alb.dns_name
  description = "The DNS name of the ALB"
}