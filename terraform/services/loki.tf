variable "loki_enabled" {
  type = bool
  description = "Enable loki integration"
  default = true
}
module "loki_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.59.0"

  count = var.loki_enabled ? 1 : 0

  role_name = format("eks-sa-loki-%s", var.environment)

  oidc_providers = {
    eks = {
      provider_arn               = data.terraform_remote_state.compute.outputs.eks.oidcIssuerArn
      namespace_service_accounts = ["monitoring:loki-s3-demo"]
    }
  }
}
resource "aws_iam_role_policy" "loki_custom_policy" {
  name = "loki-s3-demo"
  role = module.loki_irsa[0].iam_role_name

  count = var.loki_enabled ? 1 : 0

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:*",
          "Resource": [
            module.loki_s3_bucket[0].s3_bucket_arn,
            format("%s/*", module.loki_s3_bucket[0].s3_bucket_arn),
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:ListBucketVersions",
            "s3:ListBucketMultipartUploads",
            "s3:ListBucket",
            "s3:GetEncryptionConfiguration",
            "s3:GetBucketVersioning",
          ],
          "Resource":"*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "kms:GenerateDataKey",
            "kms:Decrypt"
          ],
          "Resource": module.loki_kms[0].key_arn
        }
      ]
    }
  )
}
module "loki_s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.8.0"

  count = var.loki_enabled ? 1 : 0

  bucket = format("eks-loki-logs-%s-yousef", var.environment)

  acl = "private"
  attach_public_policy = false

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = false
  restrict_public_buckets = false

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
        kms_master_key_id = module.loki_kms[0].key_arn
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "1-delete-fake-entries"
      enabled = true
      filter =[
        {
          prefix = "fake/"
        }
      ]
      expiration = {
        days = 30
      }
    },
    {
      id      = "2-logs-retention"
      enabled = true
      expiration = {
        days = 33
      }
    }
  ]
  tags = {
    CostCenter = format("s3/%s/%s", var.environment, format("eks-loki-logs-%s-yousef", var.environment))
  }
}
module "loki_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"

  count = var.loki_enabled ? 1 : 0

  description = "default storage for loki logs"
  aliases = [format("loki-%s", var.environment)]
}