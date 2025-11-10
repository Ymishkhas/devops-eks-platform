output "loki_irsa_role_arn" {
  description = "ARN of the Loki IRSA role"
  value       = var.loki_enabled ? module.loki_irsa[0].iam_role_arn : null
}
output "loki_s3_bucket_name" {
  description = "Name of the Loki S3 bucket"
  value       = var.loki_enabled ? module.loki_s3_bucket[0].s3_bucket_id : null
}
output "loki_kms_key_arn" {
  description = "ARN of the Loki KMS key"
  value       = var.loki_enabled ? module.loki_kms[0].key_arn : null
}

output "argocd_irsa_role_arn" {
  description = "ARN of the ArgoCD IRSA role"
  value       = module.argocd_irsa.iam_role_arn
}

output "alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = module.alb_irsa.iam_role_arn
}