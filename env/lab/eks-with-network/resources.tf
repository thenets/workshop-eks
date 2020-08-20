###
# Providers
###
provider "local" {
  version = "~> 1.2"
}
provider "null" {
  version = "~> 2.1"
}
provider "template" {
  version = "~> 2.1"
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

###
# VPC
###
module "vpc" {
  # Import
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6.0"

  # Main values
  name = var.project
  cidr = var.vpc_cidr_block
  azs  = data.aws_availability_zones.available.names

  # The DNS hostnames must be enable, cause it is
  # used by EKS to find the Work Node instances
  enable_dns_hostnames = true

  # Single NAT Gateway
  # It's necessary to allow EC2 instances to join
  # into the clusters as Work Nodes.
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Public subnets
  # It'll handle all the NAT Gatewys and ELB.
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
    "kubernetes.io/cluster/${var.project}" = "shared"
  }

  public_subnet_tags = {
    "Environment" = var.environment
    "Project"     = var.project

    # All cluster's subnets must have this tag
    "kubernetes.io/cluster/${var.project}" = "shared"

    # Makes the ELB be able to be create into these subnets
    "kubernetes.io/role/elb" = "1"
  }
}

###
# Kubernetes Cluster
###
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 9.0.0"

  cluster_name    = var.project
  cluster_version = "1.17"
  vpc_id          = module.vpc.vpc_id

  subnets = module.vpc.private_subnets

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.medium"
      asg_max_size         = 5
      asg_desired_capacity = 1
    }
  ]
}