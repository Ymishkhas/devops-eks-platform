module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.59.0"

  role_name = format("eks-sa-alb-%s", var.environment)
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = data.terraform_remote_state.compute.outputs.eks.oidcIssuerArn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}
