variable "environment" {
  type        = string
  description = "The environment name, e.g., dev, main"
  default     = "demo"
}
variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
  validation {
    condition     = can(regex("^(us|eu)-(east|west|north|south|central)-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format of 'us-east-1', 'eu-west-1', etc."
  }
}
