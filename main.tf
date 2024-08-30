resource "aws_vpc" "rakeshvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "rakesh-vpc"
    }
}

resource "aws_subnet" "rakeshsub" {
  vpc_id                  = aws_vpc.rakeshvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "rakeshigw" {
  vpc_id = aws_vpc.rakeshvpc.id
}

resource "aws_route_table" "rakeshrt" {
  vpc_id = aws_vpc.rakeshvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rakeshigw.id
  }
}

resource "aws_route_table_association" "rakeshrta" {
  subnet_id      = aws_subnet.rakeshsub.id
  route_table_id = aws_route_table.rakeshrt.id
}

resource "aws_security_group" "rakeshSg" {
  name   = "web"
  vpc_id = aws_vpc.rakeshvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rakesh-sg"
  }
}

resource "aws_instance" "rakeshinst" {
  ami                    = "ami-066784287e358dad1"
  instance_type          = "t2.micro"
  key_name      = "rakeshdevops"
  vpc_security_group_ids = [aws_security_group.rakeshSg.id]
  subnet_id              = aws_subnet.rakeshsub.id
}

resource "aws_s3_bucket" "rakesh_bucket" {
  bucket = "rakesh-s3" 
}
