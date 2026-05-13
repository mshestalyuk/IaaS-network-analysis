include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "../../../modules/ec2"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    public_subnet_id  = "subnet-00000000000000000"
    private_subnet_id = "subnet-00000000000000001"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show", "destroy"]
}

dependency "sg" {
  config_path = "../security-groups"

  mock_outputs = {
    bastion_sg_id = "sg-00000000000000000"
    web_sg_id     = "sg-00000000000000001"
    db_sg_id      = "sg-00000000000000002"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show", "destroy"]
}

inputs = {
  project           = "security-lab"
  public_subnet_id  = dependency.vpc.outputs.public_subnet_id
  private_subnet_id = dependency.vpc.outputs.private_subnet_id
  bastion_sg_id     = dependency.sg.outputs.bastion_sg_id
  web_sg_id         = dependency.sg.outputs.web_sg_id
  db_sg_id          = dependency.sg.outputs.db_sg_id
  ssh_public_key    = local.env.locals.ssh_key

  # Don't forget these from earlier — needed because user_data file() paths
  # don't resolve from inside .terragrunt-cache
  web_user_data = file("${get_repo_root()}/scripts/user-data/web-server.sh")
  db_user_data  = file("${get_repo_root()}/scripts/user-data/db-server.sh")
}