# VPC Configuration

data "aws_availability_zones" "available" {}

locals {
  exclude_az = "us-east-1e"  # Az excluída pois EKS não suporta a criação de instâncias do control plane na zona de disponibilidade us-east-1e
  filtered_azs = [
    for az in data.aws_availability_zones.available.names : az
    if az != local.exclude_az
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.vpc_cidr

  azs             = local.filtered_azs
  private_subnets = [for i in range(length(data.aws_availability_zones.available.names)) : cidrsubnet(var.vpc_cidr, 8, i + 1)]
  public_subnets  = [for i in range(length(data.aws_availability_zones.available.names)) : cidrsubnet(var.vpc_cidr, 8, i + 100)]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway
  
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = var.tags
}