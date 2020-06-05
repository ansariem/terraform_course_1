# AWS access Key
variable "access_key" {
  default = "---"
#  default = "${file("access_key")}"
}

# AWS secret key
variable "secret_key" {
  default = "---"
 # default = "${file("secret_key")}"
}

# AWS Region
variable "region" {
  default = "us-east-1"
}

# AWS AMI
variable "ami" {
  default = "ami-0015b9ef68c77328d"
}

# AWS Key
variable "mykey" {
  default = "ansarivirginiakey"
}
