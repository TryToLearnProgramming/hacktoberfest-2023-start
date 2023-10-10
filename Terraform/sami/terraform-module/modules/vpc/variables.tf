# modules/vpc_dem/variables.tf

variable "name" {
  description = "CIDR block for the VPC"
  type = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  description = "List of Public CIDR blocks for subnets in the VPC"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "List of Private CIDR blocks for subnets in the VPC"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of Availability Zones for subnets"
  type        = list(string)
}

variable "create_eip" {
  description = "variable for EIP"
  default = false
}
variable "create_nat" {
  description = "variable for NAT"
  default = false
}