packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.0"
    }
  }
}

variable "aws_region" {
  description = "AWS region to deploy the Packer image"
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to use"
  default     = "t2.xlarge"
}

variable "ami_name" {
  description = "Name of the created AMI"
  default     = "minecraft-server-ami"
}

source "amazon-ebs" "ubuntu" {
  region                 = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  instance_type          = var.instance_type
  ssh_username           = "ubuntu"
  ami_name               = var.ami_name
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
        "sudo DEBIAN_FRONTEND=noninteractive apt-get update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common",
        "sudo add-apt-repository ppa:openjdk-r/ppa -y",
        "sudo apt-get update",
        "sudo DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-17-jre-headless screen wget",
        "sudo ufw allow 25565",
        "sudo mkdir -p /opt/minecraft",
        "sudo wget https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar -O /opt/minecraft/minecraft_server.jar",
        "echo 'eula=true' | sudo tee /opt/minecraft/eula.txt",
        "echo 'online-mode=false' | sudo tee -a /opt/minecraft/server.properties",
        "echo '#!/bin/bash\ncd /opt/minecraft\nscreen -dmS minecraft java -Xms1024M -Xmx14G -jar minecraft_server.jar nogui' | sudo tee /opt/minecraft/start_minecraft.sh",
        "sudo chmod +x /opt/minecraft/start_minecraft.sh",
        "sudo chown -R ubuntu:ubuntu /opt/minecraft",
        "sudo chmod -R 755 /opt/minecraft",
        "echo '[Unit]\nDescription=Minecraft Server\nAfter=network.target\n\n[Service]\nType=forking\nUser=ubuntu\nWorkingDirectory=/opt/minecraft\nExecStart=/opt/minecraft/start_minecraft.sh\nRestart=always\n\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/minecraft.service",
        "sudo systemctl enable minecraft.service",
        "sudo systemctl start minecraft.service"
    ]
  }
}
