# provider.tf
provider "aws" {
  region = "us-east-1"
}

# backend.tf
terraform {
  backend "s3" {
    bucket         = "tf-state-file-depi"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # dynamodb_table = "terraform-lock-table" # Optional for state locking
  }
}

# vpc.tf
resource "aws_vpc" "main_vpc_depi" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_depi" {
  vpc_id     = aws_vpc.main_vpc_depi.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true  # Enable public IPs for instances in this subnet
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc_depi.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc_depi.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet_depi.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "allow_ports_depi" {
  vpc_id = aws_vpc.main_vpc_depi.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

    ingress {
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ec2.tf
resource "aws_instance" "web" {
  ami           = "ami-005fc0f236362e99f"  # Change to your preferred AMI
  instance_type = "t3.small"
  availability_zone = "us-east-1a"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.subnet_depi.id
  security_groups        = [aws_security_group.allow_ports_depi.id]
  key_name               = "server--key"  # Make sure to have this key pair

  # Root block device configuration to set size to 20GB
  root_block_device {
    volume_size = 20   # Size in GB
    volume_type = "gp2" # You can also use "gp3" or other types
  }
  tags = {
    Name = "Terraform-EC2"
  }
}

# output.tf
output "instance_ip" {
  value = aws_instance.web.public_ip
}

