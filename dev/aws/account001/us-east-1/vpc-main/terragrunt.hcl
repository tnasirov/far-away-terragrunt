terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.7.1"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "cloud" {
  path = find_in_parent_folders("cloud.hcl")
}

locals {
  my_env       = include.root.locals.my_env_conf.locals.my_env
  my_region    = include.root.locals.my_region_conf.locals.my_region
  cluster_name = "eks-main"
}

inputs = {
  name             = "main"
  cidr             = "10.2.0.0/16"
  azs              = ["${local.my_region}a", "${local.my_region}b", "${local.my_region}c"]
  private_subnets  = ["10.2.0.0/20", "10.2.16.0/20", "10.2.32.0/20"]
  public_subnets   = ["10.2.48.0/20", "10.2.64.0/20", "10.2.80.0/20"]
  database_subnets = ["10.2.96.0/20", "10.2.112.0/20", "10.2.128.0/20"]

  private_subnet_tags = {
    "subnet_type"                                 = "private",
    "kubernetes.io/role/internal-elb"             = "1",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "karpenter.sh/discovery"                      = "${local.cluster_name}"
  }
  public_subnet_tags = {
    "subnet_type"                                 = "public",
    "kubernetes.io/role/elb"                      = "1",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
  }
  database_subnet_tags          = { "subnet_type" : "database" }
  enable_nat_gateway            = true
  single_nat_gateway            = true
  enable_dns_hostnames          = true
  manage_default_security_group = true

  tags = merge(
    include.root.inputs.common_tags,
    {
      infra = true
    }
  )
}