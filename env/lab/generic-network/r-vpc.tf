data "aws_availability_zones" "available" {}

# VPC optimized for EKS support
module "vpc" {
  # Import
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.6.0"

  # Main values
  name = var.project
  cidr = var.vpc_cidr_block
  azs  = data.aws_availability_zones.available.names

  # The DNS hostnames must be enable, cause is
  # used by EKS to find the Work Node instancies
  enable_dns_hostnames = true

  # Single NAT Gateway
  # Necessary to allow EC2 instances join into the
  # clusters as Work nodes.
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Public subnets
  # It will handle all the NAT Gatewys, ELB and ALB.
  public_subnets = [
    cidrsubnet(var.vpc_cidr_block, 8, 1),
    cidrsubnet(var.vpc_cidr_block, 8, 2)
  ]

  # Private subnets
  # It'll be used by Work Nodes to spawn Pods.
  private_subnets = [
    cidrsubnet(var.vpc_cidr_block, 8, 4),
    cidrsubnet(var.vpc_cidr_block, 8, 5)
  ]

  tags = {
    "Environment" = var.environment
    "Project"     = var.project

    # All cluster's resources must have this tag
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "Environment" = var.environment
    "Project"     = var.project

    # All cluster's subnets must have this tag
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"

    # Makes the ELB and ALB be able to be create into these subnets
    "kubernetes.io/role/elb" = "1"
  }
}
