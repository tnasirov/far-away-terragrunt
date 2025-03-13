terraform {
  source = "git@github.com:tnasirov/far-away-terraform.git//aws/eks" # can be versioned
}

# For Inputs
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

# For AWS provider & tfstate S3 backand
include "cloud" {
  path = find_in_parent_folders("cloud.hcl")
}

dependency "vpc" {
  config_path  = "../../vpc-main"
  mock_outputs = {
    vpc_id             = "vpc-1234"
    private_subnets    = ["subnet-3", "subnet-4"]
  }
}

locals {
  my_env               = include.root.locals.my_env_conf.locals.my_env
  cluster_name         = "eks-main"
}

inputs = {
  cluster_name       = local.cluster_name
  kubernets_version  = "1.30"
  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_groups = {
    eks-eks_managed_ng = {
      name         = local.cluster_name
      desired_size = 2
      min_size     = 2
      max_size     = 3
      labels = {
        role = "spot"
      }
      instance_types = ["m6i.large", "m6i.xlarge", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge", "t2.large", "t2.xlarge", "t3.large", "t3.xlarge"]
      capacity_type  = "SPOT"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 20
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            delete_on_termination = true
          }
        }
      }
    }
  }

# For access to another IAM role

  # access_entries = {
  #   readonly = {
  #     principal_arn = "arn:aws:iam::123456789012:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_ReadOnlyAccess_xxxxxxxxxxxxx"
  #     type          = "STANDARD"
  #     policy_associations = {
  #       admin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }  
  tags = include.root.inputs.common_tags
}
