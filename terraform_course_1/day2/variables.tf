# AWS access Key
variable "aws_access_key" {
  default = "xxx"
}

# AWS secret key
variable "aws_secret_key" {
  default = "xxx"
}

# AWS Region
variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidrs" {
  type    = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  type    = "list"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

/*variable "nat" {
  default = ""
}*/
