module "kms_sops" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"

  description             = "demo-sops"
  deletion_window_in_days = 10
  enable_key_rotation     = false
  is_enabled              = true

  # Aliases
  aliases = ["demo-sops"]

  # Key administrators
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  # Key users (can use the key for encryption/decryption)
  key_users = [
    data.aws_caller_identity.current.arn
    # ArgoCD IRSA role will be added later
  ]

  tags = {
    Name = "kms-sops-${var.environment}"
  }
}