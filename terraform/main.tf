terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "mental-health-ai-companion"
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
  default     = "your-dockerhub-username"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

resource "local_file" "env_config" {
  filename = "${path.module}/../.env.generated"
  content  = <<-EOT
    APP_NAME=${var.app_name}
    ENVIRONMENT=${var.environment}
    DOCKER_IMAGE_BACKEND=${var.docker_username}/mental-health-backend:latest
    DOCKER_IMAGE_FRONTEND=${var.docker_username}/mental-health-frontend:latest
  EOT
}

output "app_name" {
  value = var.app_name
}

output "backend_image" {
  value = "${var.docker_username}/mental-health-backend:latest"
}

output "frontend_image" {
  value = "${var.docker_username}/mental-health-frontend:latest"
}
