variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key name for the EC2 instance"
  type        = string
}

variable "monitoring" {
  description = "Enable/disable detailed monitoring"
  type        = bool
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the instance"
  type        = map(string)
}

variable "associate_public_ip_address" {
  description = "Allow public IP"
  type        = bool
}
