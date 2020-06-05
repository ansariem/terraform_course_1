# os ssh Key
variable "my_public_key" {}
variable "instance_type" {}
variable "security_group" {}
variable "subnets" {
  type = "list"
}
#variable "availability-zones" {
#  default = [
#    "us-east-2a",
#    "us-east-2b",
#    "us-east-2c",
#    "us-east-3d"
#  ]
#  type = "list"
#}
