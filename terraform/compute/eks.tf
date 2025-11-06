data "aws_eks_cluster_auth" "eks" {
  name = format("eks-%s-%s", var.organization_name, var.environment)
}
variable "control_eks_rbac_auth" {
  description = "Control EKS RBAC auth"
  type        = bool
  default     = true
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.1.4"

  name = format("eks-%s-%s", var.organization_name, var.environment)
  kubernetes_version = var.eks_cluster_version
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access           = true
  security_group_name = format("eks-controlPlane-%s-%s", var.organization_name, var.environment)
  iam_role_name = format("eks-clusterRole-%s-%s", var.organization_name, var.environment)
  iam_role_use_name_prefix = false
  security_group_use_name_prefix = false
  node_security_group_use_name_prefix = false
  create_node_iam_role = false
  node_iam_role_use_name_prefix = false
  create_node_security_group = false
  encryption_policy_use_name_prefix = false
  cloudwatch_log_group_class = "INFREQUENT_ACCESS"
  cloudwatch_log_group_retention_in_days = 90
  addons = {
    kube-proxy             = {
      before_compute = true
    }
    vpc-cni                = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    coredns = {
      before_compute = true
    }
    aws-ebs-csi-driver     = {}
    aws-efs-csi-driver     = {}
    snapshot-controller    = {}
  }
  vpc_id                   = data.terraform_remote_state.network.outputs.aws_vpc.vpc_id
  subnet_ids               = data.terraform_remote_state.network.outputs.aws_vpc.subnets.private
  control_plane_subnet_ids = data.terraform_remote_state.network.outputs.aws_vpc.subnets.public
  security_group_additional_rules = {
    ingress = {
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "ingress"
      cidr_blocks              = [data.terraform_remote_state.network.outputs.aws_vpc.vpc_cidr_block]
    }
    egress = {
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 0
      type                       = "egress"
      cidr_blocks              = ["0.0.0.0/0"]
    }
  }
  eks_managed_node_groups = {
    default = {
      iam_role_name  = format("eks-nodeGroup-default-%s-%s", var.organization_name, var.environment)
      instance_types = ["t3a.medium"]
      iam_role_use_name_prefix = false
      security_group_use_name_prefix = false
      launch_template_use_name_prefix = false
      use_name_prefix = false
      ami_type       = "AL2023_x86_64_STANDARD"
      min_size     = 3
      max_size     = 3
      desired_size = 3

      use_latest_ami_release_version = false
      ami_release_version="1.33.5-20251103"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 3
        "HttpProtocolIpv6": "disabled"
      }

      taints = {
        criticalAddons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
      labels = {
        role = "default"
        "karpenter.sh/controller" = "true"
        Name = format("%s-%s-%s", "default", var.organization_name, var.environment)
      }
      iam_role_additional_policies = {
        ebs = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        efs = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      iam_role_tags = {
        CostCenter = format("eks/node-group/default/iam-role/%s", format("eks-%s-%s", var.organization_name, var.environment))
      }
      launch_template_tags = {
        CostCenter = format("eks/node-group/default/launch-template/%s", format("eks-%s-%s", var.organization_name, var.environment))
      }
      security_group_tags = {
        CostCenter = format("eks/node-group/default/security-group/%s", format("eks-%s-%s", var.organization_name, var.environment))
      }
      tags = {
        CostCenter = format("eks/node-group/default/%s", format("eks-%s-%s", var.organization_name, var.environment))
      }
    }
  }
  node_iam_role_additional_policies = {
    ebs = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    efs = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  cloudwatch_log_group_tags = {
    CostCenter = format("eks/cloudwatch/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  cluster_tags = {
    CostCenter = format("eks/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  encryption_policy_tags = {
    CostCenter = format("eks/encryption/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  iam_role_tags = {
    CostCenter = format("eks/iam-role/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  node_iam_role_tags = {
    CostCenter = format("eks/node-iam-role/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  node_security_group_tags = {
    CostCenter = format("eks/node-sg/%s", format("eks-%s-%s", var.organization_name, var.environment))
    "karpenter.sh/discovery" = "owned"
  }
  security_group_tags = {
    CostCenter = format("eks/sg/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  tags = {
    CostCenter = format("eks/%s", format("eks-%s-%s", var.organization_name, var.environment))
    "owner" = format("eks-%s-%s", var.organization_name, var.environment)
  }
}

module "eks_karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.1.4"

  cluster_name = format("eks-%s-%s", var.organization_name, var.environment)
  access_entry_type = "EC2_LINUX"
  iam_policy_use_name_prefix = false
  iam_role_use_name_prefix = false
  node_iam_role_use_name_prefix = false
  create_pod_identity_association = true
  iam_policy_name = format("KarpenterController-%s", var.environment)
  namespace = "karpenter"
  iam_role_name = format("eks-karpenter-controller-role-%s-%s", var.organization_name, var.environment)
  node_iam_role_name = format("eks-karpenter-node-role-%s-%s", var.organization_name, var.environment)
  node_iam_role_additional_policies = {
    ebs = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    efs = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  queue_name = format("eks-sqs-karpenter-%s", var.environment)
  iam_role_tags = {
    CostCenter = format("eks/karpenter/iam-role/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  node_iam_role_tags = {
    CostCenter = format("eks/karpenter/node-iam-role/%s", format("eks-%s-%s", var.organization_name, var.environment))
  }
  tags = {
    CostCenter = format("eks/karpenter/%s", format("eks-%s-%s", var.organization_name, var.environment))
    "owner" = format("eks-%s-%s", var.organization_name, var.environment)
  }
}

# AWS Auth ConfigMap (RBAC)
# Maps IAM roles/users to Kubernetes RBAC
resource "kubernetes_config_map" "aws_auth" {
  count = var.control_eks_rbac_auth ? 1 : 0
  
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  
  data = {
    mapRoles = yamlencode([
      # Default node group
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/eks-nodeGroup-default-${var.organization_name}-${var.environment}"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      },
      # Karpenter nodes
      {
        rolearn  = "arn:aws:iam::${var.account_id}:role/eks-karpenter-node-role-${var.organization_name}-${var.environment}"
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
    
    mapUsers = yamlencode([
      # IAM users
      {
        userarn  = "arn:aws:iam::${var.account_id}:user/yousef.mishkhas@techrar.com"
        username = "yousef.mishkhas@techrar.com"
        groups   = ["system:masters"]
      },
      {
        userarn  = "arn:aws:iam::${var.account_id}:user/terraform-cloud"
        username = "terraform-cloud"
        groups   = ["system:masters"]
      }
    ])
  }
  
  lifecycle {
    prevent_destroy = false
  }
}