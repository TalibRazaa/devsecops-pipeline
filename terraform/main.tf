terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t2.micro" # free-tier eligible
}

# Security group: only allow what's needed (SSH from your IP, HTTP from anywhere)
resource "aws_security_group" "app_sg" {
  name        = "devsecops-app-sg"
  description = "Allow SSH and app traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    description = "App"
    from_port   = 5000
    to_port     = 5000
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

variable "my_ip_cidr" {
  description = "Your IP in CIDR form, e.g. 1.2.3.4/32 — never leave SSH open to 0.0.0.0/0"
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0f5ee92e2d63afc18" # Amazon Linux 2023, ap-south-1 — verify current AMI ID
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "devsecops-pipeline-demo"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}
