# Security Group 1: Public Web (for Load Balancers)
module "public_web_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = format("TCP-web-%s-%s", var.app_name, var.environment)
  description     = "Allow TLS inbound traffic"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  # Allow traffic from anywhere (since i am not using cloudflare)
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS from internet"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP from internet"
      cidr_blocks = "0.0.0.0/0"
    },
        {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow encrypted connect via NAT"
      cidr_blocks = local.nat_public_ips_string
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow encrypted connect via NAT"
      cidr_blocks = local.nat_public_ips_string
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP from VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = format("TCP-web-%s-%s", var.app_name, var.environment)
    "karpenter.sh/discovery" = "owned"
    format("kubernetes.io/cluster/%s-%s", var.app_name, var.environment) = "owned"
  }
}

# Security Group 2: EFS Shared (for persistent storage)
module "efs_shared_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = "efs-shared"
  description     = "Allow machines to mount EFS"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "Allow EFS mount"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = "efs-shared"
  }
}

# Security Group 3: Karpenter Nodes
module "karpenter_nodes_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = "karpenter-nodes"
  description     = "Open ports for Karpenter-provisioned nodes"
  vpc_id          = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc.vpc_cidr_block
      description = "Allow all traffic from VPC (for Karpenter nodes)"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name = "karpenter-nodes"
    "karpenter.sh/discovery" = "owned"
    format("kubernetes.io/cluster/%s-%s", var.app_name, var.environment) = "owned"
  }
}