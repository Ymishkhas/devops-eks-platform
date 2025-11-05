module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  # Basic VPC Configuration
  name = format("%s-%s", var.app_name, var.environment)
  cidr = "10.0.0.0/16"

  # Availability Zones
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Global Configuration
  create_igw = true
  create_multiple_public_route_tables = false

  # NAT Gateway Configuration
  enable_nat_gateway = true
  single_nat_gateway = true  # Cost optimization for demo
  one_nat_gateway_per_az = false

  # Route Tables Configuration
  # (Handled automatically by module for public/private subnets)

  # NACL Configuration
  default_network_acl_name = "NACL"
  public_dedicated_network_acl = false
  private_dedicated_network_acl = false

  # DNS Configuration
  # enable_dns_hostnames = true
  # enable_dns_support   = true

  # Tags
  vpc_tags = {
    Name = format("vpc-%s-%s", var.app_name, var.environment)
  }
  igw_tags = {
    Name = format("igw-%s-%s", var.app_name, var.environment)
  }
  nat_gateway_tags = {
    Name = format("natgw-%s-%s", var.app_name, var.environment)
  }
  nat_eip_tags = {
    Name = format("nat-eip-%s-%s", var.app_name, var.environment)
  }
  public_route_table_tags = {
    Name = format("rt-public-%s-%s", var.app_name, var.environment)
  }
  private_route_table_tags = {
    Name = format("rt-private-%s-%s", var.app_name, var.environment)
  }
  default_route_table_tags = {
    Name = format("rt-default-%s-%s", var.app_name, var.environment)
  }
  default_network_acl_tags = {
    Name = format("nacl-default-%s-%s", var.app_name, var.environment)
  }
  public_acl_tags = {
    Name = format("nacl-public-%s-%s", var.app_name, var.environment)
  }
  private_acl_tags = {
    Name = format("nacl-private-%s-%s", var.app_name, var.environment)
  }
  default_security_group_tags = {
    Name = format("sg-default-%s-%s", var.app_name, var.environment)
  }

  # SUBNETS: Public
  # For: NAT Gateway, Load Balancers
  public_subnets = [
    "10.0.0.0/24",   # us-east-1a
    "10.0.1.0/24",   # us-east-1b
  ]

  public_subnet_names = [
    "public-1",
    "public-2",
  ]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"  # Required for AWS Load Balancer Controller
    Name = format("subnet-public-%s-%s", var.app_name, var.environment)
  }

  # SUBNETS: Private
  # For: EKS Worker Nodes
  private_subnets = [
    "10.0.10.0/24",  # us-east-1a
    "10.0.11.0/24",  # us-east-1b
  ]

  private_subnet_names = [
    "private-1",
    "private-2",
  ]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery" = "owned"  # For Karpenter node provisioning
    Name = format("subnet-private-%s-%s", var.app_name, var.environment)
  }
}