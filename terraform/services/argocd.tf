module "argocd_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.59.0"

  role_name = format("eks-sa-argocd-%s", var.environment)

  oidc_providers = {
    eks = {
      provider_arn               = data.terraform_remote_state.compute.outputs.eks.oidcIssuerArn
      namespace_service_accounts = ["argocd:eks-argocd-demo"]
    }
  }
}
resource "aws_iam_role_policy" "argocd_custom_policy" {
  name = "argocd-kms-demo"
  role = module.argocd_irsa.iam_role_name

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt"
          ],
          "Resource": [
            data.terraform_remote_state.global.outputs.kms_sops_arn,
            "arn:aws:kms:us-east-1:412514615512:alias/demo-sops"
          ]
        }
      ]
    }
  )
}