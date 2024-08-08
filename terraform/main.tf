#########################################################
# Provider Configuration
#########################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.project_name
}

#########################################################
# VPC Configuration
#########################################################

data "aws_availability_zones" "available" {}

locals {
  exclude_az = "us-east-1e"  # Az excluída pois EKS não suporta a criação de instâncias do control plane na zona de disponibilidade us-east-1e
  filtered_azs = [
    for az in data.aws_availability_zones.available.names : az
    if az != local.exclude_az
  ]
}

module "vpc" {
  source                  = "./modules/vpc"
  name                    = var.vpc_name
  vpc_cidr                = var.vpc_cidr
  private_subnets         = [for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, 8, i + 1)]
  public_subnets          = [for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, 8, i + 100)]
  enable_nat_gateway      = false
  single_nat_gateway      = true
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true
  tags = {
    Owner       = "Terraform"
    Environment = "prod"
  }
}

#########################################################
# EC2
#########################################################

module "ec2" {
  source = "./modules/ec2"

  instance_name               = var.ec2_name
  instance_type               = var.ec2_type
  key_name                    = var.ec2_keypair_name
  monitoring                  = var.ec2_monitoring
  vpc_security_group_ids      = [module.sg_ec2.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = var.ec2_public_ip
  tags = {
    Owner       = "Terraform"
    Environment = "prod"
  }
}

# resource "aws_eip" "ec2" {
#   instance = module.ec2.id
#   domain   = "vpc"
# }

data "aws_secretsmanager_secret_version" "ec2_key_pair" {
  secret_id = aws_secretsmanager_secret.ec2_key_pair.id
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.ec2_keypair_name
  public_key = data.aws_secretsmanager_secret_version.ec2_key_pair.secret_string
}

########################################################
# RDS
########################################################

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds-maria-db-toolzz"

  engine            = "mariadb"
  engine_version    = "10.11"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name  = "parametrizaDev"
  username = "toolzz"
  port     = "3306"
  
  iam_database_authentication_enabled = true
  publicly_accessible                 = false
  vpc_security_group_ids              = [module.sg_rds.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  monitoring_interval    = "30"
  monitoring_role_name   = "DSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "Terraform"
    Environment = "prod"
  }

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = "mariadb10.11"

  # DB option group
  major_engine_version = "10.11"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    # {
    #   name  = ""
    #   value = ""
    # },
    # {
    #   name  = ""
    #   value = ""
    # }
  ]

  options = [
    # {
    #   option_name = ""

    #   option_settings = [
    #     {
    #       name  = ""
    #       value = ""
    #     },
    #     {
    #       name  = ""
    #       value = ""
    #     },
    #   ]
    # },
  ]
}

########################################################
# EKS
########################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "cluster-toolzz"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_group_defaults = {
    instance_types = ["m5.large"]
  }

  eks_managed_node_groups = {
    app_nodes = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    admin_access = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::730030264199:role/EKSFullAccessRole"

      policy_associations = {
        admin_access = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = {
    Environment = "prd"
    Terraform   = "true"
  }
}

########################################################
# Secrets Manager
########################################################

# Public Key - EC2

resource "aws_secretsmanager_secret" "ec2_key_pair" {
  name        = "ec2-key-secret"
  description = "EC2 key pair public key"
}

resource "aws_secretsmanager_secret_version" "ec2_key_pair" {
  secret_id     = aws_secretsmanager_secret.ec2_key_pair.id
  secret_string = var.ec2_keypair_public_key
}

#########################################################
# Secutiry Groups Configuration
#########################################################

module "sg_ec2" {
  source        = "./modules/security_groups"
  name          = "ec2"
  description   = "Allow inbound traffic"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Name = "sg_ec2"
  }
}

module "sg_rds" {
  source        = "./modules/security_groups"
  name          = "rds-toolzz"
  description   = "Allow MySQL/MariaDB inbound traffic"
  vpc_id        = module.vpc.vpc_id
  ingress_rules = [
    {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.sg_ec2.security_group_id]
    },
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Name = "sg-rds-toolzz"
  }
}

#########################################################
# IAM
#########################################################

resource "aws_iam_policy" "eks_full_access_policy" {
  name        = "EKSFullAccessPolicy"
  description = "Policy granting full access to EKS and related resources"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "eks:*",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRouteTables"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "iam:ListAttachedRolePolicies",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListRoleTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "eks_full_access_role" {
  name = "EKSFullAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_full_access_role_policy_attachment" {
  policy_arn = aws_iam_policy.eks_full_access_policy.arn
  role     = aws_iam_role.eks_full_access_role.name
}
