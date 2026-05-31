include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/security-groups"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id   = "vpc-00000000000000000"
    vpc_cidr = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show", "destroy"]
}

inputs = {
  project  = "security-lab"
  vpc_id   = dependency.vpc.outputs.vpc_id
  vpc_cidr = dependency.vpc.outputs.vpc_cidr
  admin_ip = local.env.locals.admin_ip
}