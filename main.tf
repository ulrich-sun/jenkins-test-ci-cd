provider "aws" {
  region = "us-east-1"
}


variable "projet_name" {
    default = "sun"
}
resource "aws_instance" "sun" {
  ami           = "ami-0e86e20dae9224db8"  # Remplacez par l'AMI de votre choix
  instance_type = "t2.medium"
  key_name = "sun"
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "yes"
  }

 provisioner "local-exec" {
    command = "echo IP: ${self.public_ip} > /var/jenkins_home/workspace/test/instance_ip.txt"
  }
}



output "instance_ip" {
  value = aws_instance.sun.public_ip
}
resource "aws_security_group" "my_sg" {
  name        = "${var.maintainer}-sg"
  description = "Allow http, https  and ssh inbound traffic"

  ingress {
    description      = "all"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP from all"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from all"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "odoo from all"
    from_port        = 8069
    to_port          = 8069
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ic-webapp from all"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "pgadmin from all"
    from_port        = 5050
    to_port          = 5050
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "postgres from all"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.maintainer}-sg"
  }
}
output "output_sg_name" {
  value = aws_security_group.my_sg.name
}
variable "maintainer" {
  type    = string
  default = "yes"
}
