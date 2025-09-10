terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# -------------------------
# VPC + Networking
# -------------------------
resource "aws_vpc" "trend_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "trend-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "trend-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.trend_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = { Name = "trend-public-b" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.trend_vpc.id
  tags   = { Name = "trend-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.trend_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = { Name = "trend-public-rt" }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.trend_vpc.id
  name   = "trend-sg"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow App on 3000"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "trend-app-sg" }
}

# -------------------------
# IAM Role for EC2
# -------------------------
resource "aws_iam_role" "trend_ec2_role" {
  name = "trend-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "trend_ec2_profile" {
  name = "trend-ec2-profile-v2"
  role = aws_iam_role.trend_ec2_role.name
}


# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "trend_app" {
  ami           = "ami-02d26659fd82cf299" # Ubuntu 22.04 in ap-south-1
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.trend_ec2_profile.name
  key_name             = "ec2-key-pair" # Replace with your actual key pair name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              docker run -d -p 3000:3000 madhan14/project-2:v1
              EOF

  tags = { Name = "trend-ec2" }
}
