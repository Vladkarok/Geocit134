#Get Ubuntu ami
data "aws_ami" "ubuntu_latest" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

#Get Amazon-Linux ami
data "aws_ami" "amazon_linux_latest" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

# Create server with OS Ubuntu 20.04 for WEB
resource "aws_instance" "Ubuntu_Web" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  subnet_id              = aws_subnet.public_subnets.id
  availability_zone      = data.aws_availability_zones.available.names[0]
  key_name               = var.ssh_key_name
  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo reboot now
EOF

  tags   = {
    Name = "Ubuntu-Web"
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_instance.Amazon_Linux_DB
  ]
}

# Create server with OS Amazon-Linux for DB (PostgreSQL)
resource "aws_instance" "Amazon_Linux_DB" {
  ami                    = data.aws_ami.amazon_linux_latest.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_db.id]
  subnet_id              = aws_subnet.public_subnets.id
  availability_zone      = data.aws_availability_zones.available.names[0]
  key_name               = var.ssh_key_name
  user_data = <<EOF
#!/bin/bash
sudo amazon-linux-extras install epel -y
sudo yum update -y
sudo reboot now
EOF
  tags   = {
    Name = "Amazon Linux 2 - DB"
  }

  lifecycle {
    create_before_destroy = true
  }
}
