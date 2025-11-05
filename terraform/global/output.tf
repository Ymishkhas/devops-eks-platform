output "kms_sops_arn" {
  description = "KMS key ARN for SOPS encryption"
  value       = module.kms_sops.key_arn
}
output "kms_sops_alias" {
  description = "KMS key alias"
  value       = module.kms_sops.aliases
}

output "aws_acm" {
  description = "ACM certificates"
  value = {
    ymishkhas_cloud_cdn_acm_certificate = {
      arn                       = module.ymishkhas_cloud_cdn_acm_certificate.acm_certificate_arn
      domain_validation_options = module.ymishkhas_cloud_cdn_acm_certificate.acm_certificate_domain_validation_options
    }
  }
}

output "ymishkhas_route53_ns" {
  value       = module.route53_public_zone_ymishkhas["ymishkhas.cloud"].name_servers
  description = "Route53 NS for ymishkhas.cloud - copy these to your registrar"
}
output "current_user_arn" {
  description = "Your AWS user ARN"
  value       = data.aws_caller_identity.current.arn
}