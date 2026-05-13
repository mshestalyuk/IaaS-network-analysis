inputs = {
  project           = "security-lab"
  public_subnet_id  = dependency.vpc.outputs.public_subnet_id
  private_subnet_id = dependency.vpc.outputs.private_subnet_id
  bastion_sg_id     = dependency.sg.outputs.bastion_sg_id
  web_sg_id         = dependency.sg.outputs.web_sg_id
  db_sg_id          = dependency.sg.outputs.db_sg_id
  ssh_public_key    = local.env.locals.ssh_key

  web_user_data = file("${get_repo_root()}/scripts/user-data/web-server.sh")
  db_user_data  = file("${get_repo_root()}/scripts/user-data/db-server.sh")
}