# VPC
output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc_arn" {
  value = module.vpc.vpc_arn
}

# Public Subnets
output "public_subnets" {
  value = module.vpc.public_subnets
}
output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}
output "public_subnet_arns" {
  value = module.vpc.public_subnet_arns
}

# Private Subnets
output "private_subnets_ids" {
  value = module.vpc.private_subnets
}
output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}
output "private_subnet_arns" {
  value = module.vpc.private_subnet_arns
}
