# We Defined the AWS provider and region
provider "aws" {
  region = "eu-west-3"
}

# We Created a VPC
resource "aws_vpc" "exam_vpc" {
  cidr_block          = "10.0.0.0/16"

  tags = {
    Name = "examVPC" 
  }
}

# We Created a subnet in the VPC (Public Subnet 1)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.exam_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public1"
  }
}

# We Created a subnet in the VPC (Public Subnet 2)
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.exam_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public2"
  }
}

# We Created a subnet in the VPC (Private Subnet 1)
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.exam_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Privite1"
  }
}

# We Created a subnet in the VPC (Private Subnet 2)
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.exam_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Privite2"
  }
}

