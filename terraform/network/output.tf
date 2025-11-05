output "aws_vpc" {
  description = "VPC object exposing VPC attributes"
  value = {
    vpc_id         = module.vpc.vpc_id
    vpc_name       = module.vpc.name
    vpc_cidr_block = module.vpc.vpc_cidr_block
    subnets = {
      public  = module.vpc.public_subnets
      private = module.vpc.private_subnets
    }
    nat = {
      ids = module.vpc.natgw_ids
      ips = module.vpc.nat_public_ips
    }
  }
}

output "security_groups" {
  description = "Security groups created for the VPC"
  value = {
    public_web_security_group      = module.public_web_security_group.security_group_id
    efs_shared_security_group      = module.efs_shared_security_group.security_group_id
    karpenter_nodes_security_group = module.karpenter_nodes_security_group.security_group_id
  }
}