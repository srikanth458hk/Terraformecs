provider "aws" {
  region = "ap-south-1"  # Set your desired AWS region
}




resource "aws_ecr_repository" "example_repo" {
  name = "example-repo"  # Set your desired ECR repository name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "example_cluster" {
  name = "example-cluster"  # Set your desired ECS cluster name
}

resource "aws_ecs_task_definition" "example_task" {
  family                   = "example-task"  # Set your desired task family name
  requires_compatibilities = ["FARGATE"]
  
  cpu = 1024  # Set your desired CPU units
  memory = 2048 # Set your desired memory in MiB
  network_mode =  "awsvpc"
  #execution_role_arn = "arn:aws:iam::349898186074:role/Adminrole"

  container_definitions = <<DEFINITION
[
  {
    "name": "example-container",
    "image": "public.ecr.aws/j2d9m4m0/nodejs:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp",
         "cpu": 1024,
         "memory": 2048
      }
    ],
    "essential": true
  }
]
DEFINITION
}

resource "aws_ecs_service" "example_service" {
  name            = "example-service"  # Set your desired service name
  cluster         = aws_ecs_cluster.example_cluster.id
  task_definition = aws_ecs_task_definition.example_task.arn
  desired_count   = 1
  

  launch_type = "FARGATE"

  network_configuration {
    security_groups = ["sg-08e1e353cebe3ac37"]
    subnets         = ["subnet-0d07c761a52ecc4ee"]
    assign_public_ip = true  # Set to false if you don't want a public IP
  }
}
