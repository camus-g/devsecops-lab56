provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket_seguro" {
  bucket = "mi-bucket-devsecops-demo-12345"
}

resource "aws_s3_bucket_public_access_block" "publico" {
  bucket                  = aws_s3_bucket.bucket_seguro.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "sg_seguro" {
  name        = "sg_ssh_restringido"
  description = "Grupo de seguridad restringido para lab"

  ingress {
    description = "SSH interno unicamente desde el rango del VPC" #Corrige el CKV_AWS_23
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Corrige el CKV2_AWS_5 
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_network_interface" "eni_lab" {
  subnet_id       = data.aws_subnets.default.ids[0]
  security_groups = [aws_security_group.sg_seguro.id]
}