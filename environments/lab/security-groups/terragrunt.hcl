include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/security-groups"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  project  = "security-lab"
  vpc_id   = dependency.vpc.outputs.vpc_id
  admin_ip = local.env.locals.admin_ip
}