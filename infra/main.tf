provider "aws" {
  region = var.aws_region
}

# Security Group for Tomcat + SSH
resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat-sg"
  description = "Allow SSH and Tomcat access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Tomcat access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Launch 4 EC2 instances
resource "aws_instance" "tomcat_instances" {
  count         = length(var.tomcat_instances)
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.tomcat_sg.name]

  user_data = file("tomcat_setup.sh")

  tags = {
    Name = "${var.tomcat_instances[count.index]}-server"
    Environment = var.tomcat_instances[count.index]
  }
}
