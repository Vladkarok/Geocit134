# Add security group web
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allow_ports_web
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.all_cidr_block]
    }
  }

  ingress {
    description = "allow icmp"
    from_port   = 3
    to_port     = 4
    protocol    = "icmp"
    cidr_blocks = [var.all_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_block]
  }

  tags = {
    Name = "Allow web"
  }
}

# Add security group db
resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow db inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "ssh to ec2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.all_cidr_block]
  }
  ingress {
    description = "db to ec2"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "allow icmp"
    from_port   = 3
    to_port     = 4
    protocol    = "icmp"
    cidr_blocks = [var.all_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_cidr_block]
  }

  tags = {
    Name = "Allow db"
  }
}

