provider "aws" {
  region = var.aws_region
}

# Security Group within the given VPC
resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat-sg"
  description = "Allow SSH and Tomcat access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# EC2 Instances in specified subnet
resource "aws_instance" "tomcat_instances" {
  count         = length(var.tomcat_instances)
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]

  user_data = file("tomcat_setup.sh")

  tags = {
    Name        = "${var.tomcat_instances[count.index]}-server"
    Environment = var.tomcat_instances[count.index]
  }
}
