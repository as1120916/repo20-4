terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
}

# Configure the AWS Provider (Uses Jenkins Credential Manager environment variables)
provider "aws" {
  region = "us-east-1"
}

# Create a security group to allow SSH (22) and HTTP (80)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow inbound SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Launch EC2 instance with RHEL AMI
resource "aws_instance" "rhel_instance" {
  ami           = "ami-0c7af5fe939f2677f"  # Replace with correct AMI ID for your region
  instance_type = "t2.micro"  
  key_name      = "nvkey1"  
  security_groups = [aws_security_group.allow_ssh_http.name]

  tags = {
    Name = "rhel-server"
  }

  # Root Volume
  root_block_device {
    volume_size = 10
    volume_type = "gp2"
    encrypted   = true
  }

  # Additional storage
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 5
    volume_type = "gp2"
    encrypted   = true
  }

  # Enable public IP
  associate_public_ip_address = true
}

output "instance_public_ip" {
  value = aws_instance.rhel_instance.public_ip
}

output "instance_id" {
  value = aws_instance.rhel_instance.id
}
