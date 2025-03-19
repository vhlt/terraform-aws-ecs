resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_service_attachment" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_service_attachment_s3" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_service_attachment_secret" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "ecs_service_attachment_ses" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_ecs_cluster" "main" {
  name = "engram-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family             = "backend-service"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_service_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode       = "awsvpc" // Fargate requires awsvpc network mode
  cpu                = var.ecs_tf_backend_cpu    // CPU units for the task
  memory             = var.ecs_tf_backend_ram  // Memory (in MiB) for the task

  container_definitions = jsonencode([{
    name      = var.ecs_container_name_backend
    image     = "engram-backend-repo"
    cpu       = var.ecs_container_backend_cpu
    memory    = var.ecs_container_backend_ram
    essential = true
    portMappings = [{
      containerPort = var.api_port
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options   = {
          "awslogs-group"         = var.backend_log_group_name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "frontend" {
  family             = "frontend-service"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_service_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode       = "awsvpc" // Fargate requires awsvpc network mode
  cpu                = var.ecs_tf_frontend_cpu    // CPU units for the task
  memory             = var.ecs_tf_frontend_ram   // Memory (in MiB) for the task

  container_definitions = jsonencode([{
    name      = var.ecs_container_name_frontend
    image     = "engram-fe-repo"
    cpu       = var.ecs_container_frontend_cpu
    memory    = var.ecs_container_frontend_ram
    essential = true
    portMappings = [{
      containerPort = var.web_port
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options   = {
          "awslogs-group"         = var.frontend_log_group_name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}
# fetch latest revision and re-apply
data "aws_ecs_task_definition" "backend" {
  task_definition = aws_ecs_task_definition.backend.family
}

resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = "${aws_ecs_task_definition.backend.arn_without_revision}:${max(aws_ecs_task_definition.backend.revision, data.aws_ecs_task_definition.backend.revision)}"
  desired_count   = var.ecs_container_number_backend
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    # subnets          = [module.vpc.private_subnets[0]]
    subnets = var.multiple_zones ? module.vpc.private_subnets : [module.vpc.private_subnets[0]]
    security_groups  = [aws_security_group.ecs_service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = var.ecs_container_name_backend
    container_port   = var.api_port
  }
}
# fetch latest revision and re-apply
data "aws_ecs_task_definition" "frontend" {
  task_definition = aws_ecs_task_definition.frontend.family
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = "${aws_ecs_task_definition.frontend.arn_without_revision}:${max(aws_ecs_task_definition.frontend.revision, data.aws_ecs_task_definition.frontend.revision)}"
  desired_count   = var.ecs_container_number_frontend
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    # subnets          = [module.vpc.private_subnets[0]]
    subnets = var.multiple_zones ? module.vpc.private_subnets : [module.vpc.private_subnets[0]]
    security_groups  = [aws_security_group.ecs_service_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = var.ecs_container_name_frontend
    container_port   = var.web_port
  }
}
