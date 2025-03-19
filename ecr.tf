// Backend ECR repository
resource "aws_ecr_repository" "backend_repo" {
  count = var.use_tooling_ecr ? 0 : 1
  name                 = "engram-backend"
  image_tag_mutability = "IMMUTABLE" // Example setting for image tag mutability
  // Additional configurations as needed
}

// Frontend ECR repository
resource "aws_ecr_repository" "frontend_repo" {
  count = var.use_tooling_ecr ? 0 : 1
  name                 = "engram-frontend"
  image_tag_mutability = "IMMUTABLE" // Example setting for image tag mutability
}
