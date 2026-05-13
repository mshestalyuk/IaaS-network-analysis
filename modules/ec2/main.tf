################################################################################
# Latest Amazon Linux 2023 AMI
################################################################################
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

################################################################################
# SSH Key Pair
################################################################################
resource "aws_key_pair" "lab" {
  key_name   = "${var.project}-key"
  public_key = var.ssh_public_key
}

################################################################################
# Bastion Host (public subnet)
################################################################################
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = aws_key_pair.lab.key_name

  tags = { Name = "${var.project}-bastion" }
}

################################################################################
# Web Server (public subnet)
################################################################################
resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.web_sg_id]
  key_name               = aws_key_pair.lab.key_name

  user_data = var.web_user_data 

  tags = { Name = "${var.project}-web" }
}

################################################################################
# DB Server (private subnet)
################################################################################
resource "aws_instance" "db" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.db_sg_id]
  key_name               = aws_key_pair.lab.key_name

  user_data = var.db_user_data
  tags = { Name = "${var.project}-db" }
}
