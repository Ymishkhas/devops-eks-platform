terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version =  "~> 6"
    }
  }
  required_version = "~> 1.11"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      CostCenter          = var.environment
      "terraform.managed" = "true"
      repo                = "Ymishkhas/devops-eks-platform"
      "repo.path"         = "network/"
    }
  }
}