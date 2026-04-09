include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/ec2"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "sg" {
  config_path = "../security-groups"
}

inputs = {
  project           = "security-lab"
  public_subnet_id  = dependency.vpc.outputs.public_subnet_id
  private_subnet_id = dependency.vpc.outputs.private_subnet_id
  bastion_sg_id     = dependency.sg.outputs.bastion_sg_id
  web_sg_id         = dependency.sg.outputs.web_sg_id
  db_sg_id          = dependency.sg.outputs.db_sg_id
  ssh_public_key    = local.env.locals.ssh_key
}