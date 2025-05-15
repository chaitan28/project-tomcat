variable "aws_region" {
  description = "The AWS region to launch instances in"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 in us-east-1"
  type        = string
  default     = "ami-0e35ddab05955cf57"  # Update for your region if needed
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "aws2-ap-south"
}

variable "tomcat_instances" {
  description = "List of environments to create EC2 instances for"
  type        = list(string)
  default     = ["dev", "qa", "staging", "prod"]
}
