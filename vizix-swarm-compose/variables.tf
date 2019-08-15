#
# AWS Access
#

variable "aws_access_key" {
  description = "Enter the AWS access key."
}

variable "aws_secret_key" {
  description = "Enter the AWS secret key."
}
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

#
# SSH Access
#

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to run provisioner."
  default     = "/root/.ssh/awsqa.pem"
}

#
# Instance Details
#

variable "name" {
  description = "Enter the instance name."
  default     = "JC_Swarm"
}

variable "aws_ami" {
  description = "Enter the AWS AMI."
  default     = "ami-d231f6a8"       # Ubuntu
}

variable "instance_type" {
  description = "Enter the instance type."
//  default = "t2.xlarge"
  default = "t2.micro"
}

variable "aws_security_groups" {
  description = "security groups names"
  default = ["default", "QA-Default", "blockchain"]
//  default = ["launch-wizard-1"]
}

variable "aws_key_name" {
  description = "Name of key pair"
  default = "awsqa"
}

variable "aws_count_rulesprocessor" {
  description = "Number of rulesprocessors to use"
  default = 2
}

#
# GitHub user
#
variable "git_username" {
  description = "Username of GitHub"
}
variable "git_password" {
  description = "Password of GitHub user"
}

