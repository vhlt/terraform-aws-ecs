module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  # providers = {
  #   aws = aws.dev
  # }

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets  = var.public_cidr
  private_subnets = var.private_cidr

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
