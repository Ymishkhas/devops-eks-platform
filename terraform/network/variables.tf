variable "app_name" {
  type        = string
  description = "The name of the application, e.g., techrar"
  default     = "techrar"
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.app_name))
    error_message = "App name must be alphanumeric and can include hyphens"
  }
}

variable "environment" {
  type        = string
  description = "The environment name, e.g., dev, main"
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "Must be a valid AWS region format (e.g., us-east-1)"
  }
}
