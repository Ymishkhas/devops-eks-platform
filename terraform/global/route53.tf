module "route53_public_zone_ymishkhas" {
  source  = "terraform-aws-modules/route53/aws"
  version = "~> 6.0"

  for_each = {
    "ymishkhas.cloud" = {
      name    = "ymishkhas.cloud"
      comment = "Public hosted zone for ymishkhas.cloud"
      vpc     = null # Public zone (not private)
    }
  }

  name    = each.value.name
  comment = each.value.comment
  vpc     = each.value.vpc
}