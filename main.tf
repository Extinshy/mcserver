provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft_key"
  public_key = file("${path.module}/key.pub")  # Replace with the path to your public key
}

resource "aws_security_group" "minecraft_security_group" {
  name        = "aloda"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.minecraft_server_port
    to_port     = var.minecraft_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "minecraft_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.minecraft_key.key_name  # Use the key pair name
  security_groups = [aws_security_group.minecraft_security_group.name]

  tags = {
    Name = "Minecraft_Server_Instance"
  }
}

output "minecraft_server_address" {
  description = "Address of the Minecraft server"
  value       = "${aws_instance.minecraft_instance.public_ip}:${var.minecraft_server_port}"
}
output "minecraft_version" {
  description = "Use this MC version"
  value       = "1.18.2 Release"
}
