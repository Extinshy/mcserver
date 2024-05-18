variable "aws_region" {
  description = "AWS region to deploy the infrastructure"
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to use"
  default     = "t2.xlarge"
}

variable "ami_id" {
  description = "ID of the AMI to use for the EC2 instance"
  default     = "ami-09e3192e203ad3738"
}

variable "minecraft_server_port" {
  description = "Port on which the Minecraft server will run"
  default     = 25565
}