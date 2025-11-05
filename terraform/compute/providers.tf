terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version =  "~> 6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }
  required_version = "~> 1.11"
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment         = var.environment
      CostCenter          = var.environment
      "terraform.managed" = "true"
      repo                = "Ymishkhas/devops-eks-platform"
      "repo.path"         = "compute/"
    }
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}