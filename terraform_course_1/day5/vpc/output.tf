
#output "aws_vpc_id" {
output "vpc_id" {
  value = "${aws_vpc.ansari_main.id}"
}

output "aws_internet_gateway" {
  value = "${aws_internet_gateway.ansari_gw.id}"

}
output "security_group" {
  value = "${aws_security_group.my-ansari-sg.id}"
}

output "subnets" {
  value = "${aws_subnet.ansari_public_subnet.*.id}"
}

output "subnet1" {
  value = "${element(aws_subnet.ansari_public_subnet.*.id, 1 )}"
}

output "subnet2" {
  value = "${element(aws_subnet.ansari_public_subnet.*.id, 2 )}"
}