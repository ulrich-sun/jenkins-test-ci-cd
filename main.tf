provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0e86e20dae9224db8"  # Remplacez par l'AMI de votre choix
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleInstance"
  }
}

output "instance_ip" {
  value = aws_instance.example.public_ip
}
