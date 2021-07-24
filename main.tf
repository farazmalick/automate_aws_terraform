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
variable ip {}
variable instance_type {}
variable ssh_key{}

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

resource "aws_security_group" "myapp-sg"{
    vpc_id=aws_vpc.myapp-vpc.id
    ingress{
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=[var.ip]
    }
    ingress{
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress{
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
        prefix_list_ids=[]
    }
    tags={
        Name="myapp-sg"
    }
}

data "aws_ami" "linux-ami"{
    most_recent=true
    owners=["amazon"]
    filter{
        name="name"
        values=["amzn2-ami-hvm*gp2"]
    }
    filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# output "data"{
#     value=data.aws_ami.linux-ami.id
# }

 resource "aws_instance" "myapp-server"{
     ami=data.aws_ami.linux-ami.id
     instance_type=var.instance_type

     subnet_id=aws_subnet.myapp-subnet-1.id
     vpc_security_group_ids=[aws_security_group.myapp-sg.id]
     associate_public_ip_address=true
     key_name=var.ssh_key

     user_data=file("script.sh")

     tags={
         name="myapp-instance"
     }
     
 }