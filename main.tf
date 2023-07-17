provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"  # Set your desired VPC CIDR block
}

resource "aws_subnet" "example_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24"  # Set your desired subnet CIDR block
}

resource "aws_security_group" "example_sg" {
  vpc_id = aws_vpc.example_vpc.id

  # Add any additional inbound/outbound rules as required
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "example_repo" {
  name = "example-repo"  # Set your desired ECR repository name
}

resource "aws_ecs_cluster" "example_cluster" {
  name = "example-cluster"  # Set your desired ECS cluster name
}

resource "aws_ecs_task_definition" "example_task" {
  family                   = "example-task"  # Set your desired task family name
  requires_compatibilities = ["FARGATE"]
  
  cpu = "256"  # Set your desired CPU units
  memory = "512"  # Set your desired memory in MiB

  container_definitions = <<DEFINITION
[
  {
    "name": "example-container",
    "image": "${aws_ecr_repository.example_repo.repository_url}:latest",
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
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
    security_groups = [aws_security_group.example_sg.id]
    subnets         = [aws_subnet.example_subnet.id]
    assign_public_ip = true  # Set to false if you don't want a public IP
  }
}
