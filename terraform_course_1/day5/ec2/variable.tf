# This Variables will refer from the modules which declaired from the main.tf, where we can modify for other vpc which single pain
variable "region" {}
variable "my_public_key" {}
variable "instance_type" {}
variable "security_group" {}
variable "subnets" {
  type = "list"
}
