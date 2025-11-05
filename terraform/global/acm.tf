module "ymishkhas_cloud_cdn_acm_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = "ymishkhas.cloud"
  subject_alternative_names = [
    "*.ymishkhas.cloud"
  ]

  validation_method      = "DNS"
  create_route53_records = true # First time make it false
  wait_for_validation    = true # only first time make it false
  zone_id                = module.route53_public_zone_ymishkhas["ymishkhas.cloud"].id # comment first time

  depends_on = [
    module.route53_public_zone_ymishkhas
  ]

  tags = {
    Name = "acm-${var.environment}"
  }
}
