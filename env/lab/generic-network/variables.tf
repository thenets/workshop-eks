variable "project" {
  default = "cerulean"
}

variable "vpc_cidr_block" {
  default = "10.66.0.0/16"
}

variable "environment" {
  default = "development"
}

# Ignore if you aren't using EKS
variable "eks_cluster_name" {
  default = "exodus"
}
