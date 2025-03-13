terraform {
  source = "git@github.com:tnasirov/far-away-terraform.git//aws/core-services/engines"
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

# For Helm, Kubectl & GitHub providers
include "common_providers" {
  path = find_in_parent_folders("providers.hcl")
}

dependency "eks" {
  config_path  = "../cluster"
  mock_outputs = {
    vpc_id              = "vpc-1234"
    eks_endpoint        = "https://example.com/eks"
    eks_certificate     = "aGVsbG93b3JsZAo="
    eks_cluster_name    = "test_cluster"
    eks_oidc_provider   = "arn::test"
  }
}

inputs = {
  # argocd     
  argocd_enabled             = true
  argocd_namespace           = "argocd"
  argocd_hostname            = "argocd.dev.far.away"
  argocd_main_apps           = ["dev"]
  argocd_sso_enabled         = false
  cluster_oidc_provider      = dependency.eks.outputs.eks_oidc_provider
  tags                       = include.root.inputs.common_tags
}
