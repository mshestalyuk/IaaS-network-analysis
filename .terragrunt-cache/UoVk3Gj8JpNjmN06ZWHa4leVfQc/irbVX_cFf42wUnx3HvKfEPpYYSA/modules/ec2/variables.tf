variable "project" {
  type    = string
  default = "security-lab"
}

variable "public_subnet_id" { type = string }
variable "private_subnet_id" { type = string }
variable "bastion_sg_id" { type = string }
variable "web_sg_id" { type = string }
variable "db_sg_id" { type = string }
variable "ssh_public_key" { type = string }
