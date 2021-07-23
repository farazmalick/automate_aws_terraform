terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

variable vpc_cider_block {} 
variable subnet_cider_block {}
variable avail_zone {}

resource "aws_vpc" "myapp-vpc"{
cidr_block=var.vpc_cider_block
tags={
    Name:"myapp-vpc"
}
}

resource "aws_subnet" "myapp-subnet-1"{
    vpc_id=aws_vpc.myapp-vpc.id
    cidr_block=var.subnet_cider_block
    availability_zone=var.avail_zone
    tags={
        Name:"myapp-subnet"
    }
}

resource "aws_route_table" "myapp-rtb"{
    vpc_id=aws_vpc.myapp-vpc.id
    route{
        cidr_block="0.0.0.0/0"
        gateway_id=aws_internet_gateway.myapp-gateway.id
    }
    tags={
        Name:"myapp-rtb"
    }
}

resource "aws_internet_gateway" "myapp-gateway"{
    vpc_id=aws_vpc.myapp-vpc.id
    tags={
        Name:"myapp-igw"
    }
}

resource "aws_route_table_association" "rtb-subnet-asso"{
    subnet_id=aws_subnet.myapp-subnet-1.id
    route_table_id=aws_route_table.myapp-rtb.id
}