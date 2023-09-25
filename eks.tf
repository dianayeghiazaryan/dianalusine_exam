# Define the provider and region
provider "aws" {
  region = "eu-west-3"
}

# Reference the existing VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-03a45316caa3a5d43" 
}

# Reference the existing subnets
data "aws_subnet" "public_subnet_1" {
  id = "subnet-00cb24bbba0f146fd"
}

data "aws_subnet" "public_subnet_2" {
  id = "subnet-0f8b5ad3c0915cc2e" 
}

data "aws_subnet" "private_subnet_1" {
  id = "subnet-05076af3ea7c42ca1"
}

data "aws_subnet" "private_subnet_2" {
  id = "subnet-0cd3b4a23fd47023f"
}

# Create an EKS cluster
resource "aws_eks_cluster" "exam_cluster" {
  name     = "exam-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = [
      data.aws_subnet.public_subnet_1.id,
      data.aws_subnet.public_subnet_2.id,
    ]
  }
  tags = {
    "Name" = "exam-eks-cluster"
  }
}

# Create a worker node IAM role (if not already created)
resource "aws_iam_role" "eks_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the worker node IAM role (e.g., EKS policies)
resource "aws_iam_policy_attachment" "eks_role_attachment" {
  name = "eks-node-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles = [aws_iam_role.eks_role.name]
}

# Provide a valid Amazon Linux 2 AMI ID (replace with your desired AMI)
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

# Security Group Data Source (No need to redefine it as a resource)
data "aws_security_group" "public_sg" {
  id = "sg-0b80c68078a5b2207"
}

# Launch configuration for worker nodes
resource "aws_launch_configuration" "eks_launch_config" {
  name_prefix = "eks-workers-"
  image_id = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  security_groups = [data.aws_security_group.public_sg.id]
  user_data = <<-EOF
    #!/bin/bash
    echo 'KUBELET_EXTRA_ARGS="--node-labels=eks.amazonaws.com/capacityType=on-demand"'
  EOF
  # Add more configurations as needed
}

# Auto Scaling Group for worker nodes
resource "aws_autoscaling_group" "eks_workers_asg" {
  name = "eks-workers"
  launch_configuration = aws_launch_configuration.eks_launch_config.name
  vpc_zone_identifier = [
    data.aws_subnet.private_subnet_1.id,
    data.aws_subnet.private_subnet_2.id,
  ]
  desired_capacity = 2
  min_size = 1
  max_size = 2
}

# Define the EKS cluster outputs
output "eks_cluster_name" {
  value = aws_eks_cluster.exam_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.exam_cluster.endpoint
}
