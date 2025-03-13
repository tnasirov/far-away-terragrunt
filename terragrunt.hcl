locals {
  my_env_conf     = read_terragrunt_config(find_in_parent_folders("env.hcl", "does-not-exist.fallback"), { locals = {} })
  my_account_conf = read_terragrunt_config(find_in_parent_folders("account.hcl", "does-not-exist.fallback"), { locals = {} })
  my_region_conf  = read_terragrunt_config(find_in_parent_folders("region.hcl", "does-not-exist.fallback"), { locals = {} })
}

inputs = {
  common_tags = {
    Terragrunt     = "true"
    Environment    = local.my_env_conf.locals.my_env
    TerragruntPath = "far-away-terragrunt${split("${get_parent_terragrunt_dir()}", get_original_terragrunt_dir())[1]}"
  }
}
