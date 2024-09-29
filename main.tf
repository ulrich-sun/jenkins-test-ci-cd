provider "aws" {
  region = "us-east-1"
}


variable "projet_name" {
    default = "sun"
}
resource "aws_instance" "sun" {
  ami           = "ami-0e86e20dae9224db8"  # Remplacez par l'AMI de votre choix
  instance_type = "t2.micro"
  key_name = "sun"

  tags = {
    Name = "sunInstance"
  }

  provisioner "local-exec" {
    command = "echo IP: ${aws_instance.sun.public_ip} > /tmp/public_ip.txt"
  }
}



output "instance_ip" {
  value = aws_instance.sun.public_ip
}
