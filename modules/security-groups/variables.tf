variable "project" {
  type    = string
  default = "security-lab"
}

variable "vpc_id" {
  type = string
}

variable "admin_ip" {
  description = "Your public IP in CIDR, e.g. 1.2.3.4/32"
  type        = string
}
