provider "aws" {
  region = "us-east-1"
}
module "create_vpc" {
  source                     = "./modules/vpc"
  name                       = "test_vpc"
  availability_zones         = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_cidr_block             = "10.0.0.0/16"
  public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  # create_eip = true   # If want a EIP for NAT
  # create_nat = true   # If want a NAT
}