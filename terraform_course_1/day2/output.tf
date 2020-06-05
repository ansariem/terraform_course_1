
output "aws_vpc_id" {
  value = "${aws_vpc.ansari_main.id}"

}

output "aws_internet_gateway" {
  value = "${aws_internet_gateway.ansari_gw.id}"

}