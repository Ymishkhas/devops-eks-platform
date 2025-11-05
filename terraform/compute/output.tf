output "eks" {
  value = {
    "endpoint" = module.eks.cluster_endpoint
    "oidcIssuerUrl" = module.eks.cluster_oidc_issuer_url
    "oidcIssuerArn" = module.eks.oidc_provider_arn
    "controlPlaneSecurityGroupId" = module.eks.cluster_security_group_id
    "nodeGroupSecurityGroupIds" = module.eks.node_security_group_id
  }
}