variable "project_name" {
  description = "Project name"
  type        = string
  default     = "default"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "main"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  default     = ["subnet-0a7266e4d622156c5", "subnet-002866a142421bb1c", "subnet-0320827f73d82056f"]
}  

variable "public_subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  default     = ["subnet-0818d78467a62b0e7", "subnet-04bd5e1b41cf71719", "subnet-055ac7273865037d5"]
}

# variable "enable_nat_gateway" {
#   description = "Enable NAT Gateway"
#   type        = bool
#   default     = false
# }

# variable "single_nat_gateway" {
#   description = "Use a single NAT Gateway"
#   type        = bool
#   default     = true
# }

# variable "enable_vpn_gateway" {
#   description = "Enable VPN Gateway"
#   type        = bool
#   default     = false
# }

variable "ec2_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "ec2-toolzz"
}

variable "ec2_type" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_keypair_name" {
  description = "Keypair for the EC2 instance"
  type        = string
  default     = "ec2_keypair"
}

variable "ec2_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "ec2_public_ip" {
  description = "Associate a public IP address"
  type        = bool
  default     = true
}

variable "ec2_keypair_public_key" {
  description = "Keypair public EC2"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfChSN5FxvYQ6nsm6Sd3IK4RDBRS0eCz9XGFh3vIhG7TzEUyC8nu0YMjU1djnmA1oJyV7pBojqpXSkwuOUbkHFK85/RltpMvHVjcV6DagrHRcnibesb7r5+O+k6ksLOj+1A//t21fZgfnWqN5ck+q41duwQceNz0VcG8RX4WcbsmmZvlfpZzT7f648AWjJdtCLn6tUEpXGq0jQ3XwOTELgFUJ53DRTftnQURg1v/Io6y6FtTwaH9YKnXuRrF7Zl+vdmIp4sYQSf0vc61FhEjU7F6GaCIgbUS2kfJvPB9umh33lUX2jB2AJ8QZLfDvvYETm+CphRErCoW4xrTDHAYcO33sAdr/EgpMQDMosS3d3wBzZEIKdf75MLHzp3RoqeIw74+E12FYdP+1hVwBTXe2PVmHcirGZ5W/g9xqG8d+W7eq716dXXWHjK8tmy3XokuUH/0LxyU6U6zGQCrGSOfbblVAqmcIj0mHM1Uw9DT/vUGGS2Pj02HkB6qvZN9l8VefI24VTZVr0yoct/5loZSK6x+ubwlEGZzMV2W0hTapIznuvGpr8oz9s7bOWgqxD85yyQunj+fGZ1BZkFIyhbBOaI90REwzoKwmFlQigMrqQ4a3CCgKtkPTt8FC72GeejNtu6TNG/AL7bjdxJPpDcrVY9MgUdDbbInj8nXly9KN8XQ== toolzz@toolzz.com"
}
