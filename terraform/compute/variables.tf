variable "account_id" {
  type        = string
  description = "The AWS account ID where the resources will be created"
  default = "412514615512"
}

variable "organization_name" {
  type        = string
  description = "The name of the organization, e.g., techrar"
  default = "techrar"
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

variable "eks_cluster_version" {
  type = string
  description = "The version of the EKS cluster to create"
  default = "1.33"
}