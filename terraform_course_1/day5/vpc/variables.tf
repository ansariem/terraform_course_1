# AWS access Key
variable "aws_access_key" {
  default = "xxxx"
}

# AWS secret key
variable "aws_secret_key" {
  default = "xxxxx"
}

# AWS Region
variable "region" {
  #  default = "us-east-2"
}

variable "vpc_cidr" {
}

variable "public_cidrs" {
  type = "list"
}

variable "private_cidrs" {
  type = "list"
}
