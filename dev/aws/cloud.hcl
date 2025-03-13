locals {
  my_account_conf = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  my_region_conf  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

generate "aws_provider" {
  path      = "aws_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.my_region_conf.locals.my_region}"

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.my_account_conf.locals.account_id}"]
}
  EOF
}

iam_role = "arn:aws:iam::${local.my_account_conf.locals.account_id}:role/automation"

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "terraform-state-${local.my_account_conf.locals.account_name}-${local.my_account_conf.locals.account_id}"
    dynamodb_table = "${local.my_account_conf.locals.account_name}-terraform-state-lock"
    key            = "${path_relative_to_include()}.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}