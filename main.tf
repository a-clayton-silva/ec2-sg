terraform {
  required_version = "1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1" #regiao mais barata
  profile = "tf133"
}
#buckettf
resource "aws_s3_bucket" "buckettf" {
  bucket = "my-tf-test-bucket-tfstate"

  tags = {
    Name        = "My bucket tf state"
    Environment = "Dev"
    Managedby   = "Terraform"
    Owner       = "clayton"
    Update      = "2022-11-21"
  }
}
#buckettf
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.buckettf.id
  acl    = "private"
}

#vpc

resource "aws_vpc" "vpc-local2" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name      = "vpc-local2"
    Managedby = "Terraform"
  }
}

#vpc

resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.vpc-local2.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-private-a"
  }
}

#vpc sub

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.vpc-local2.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-private-b"
  }
}

#ec2

resource "aws_network_interface" "ubuntu-app" {
  subnet_id   = aws_subnet.private-a.id
  private_ips = ["10.1.0.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

#ec2

resource "aws_instance" "ubuntu-app" {
  ami             = "ami-08c40ec9ead489470" # us-east-1
  instance_type   = "t2.micro"
  key_name        = "dolibarr"
   tags = {
    Name = "ubuntu-app"
  }

  network_interface {
    network_interface_id = aws_network_interface.ubuntu-app.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}
