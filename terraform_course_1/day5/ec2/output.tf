output "instance1_id" {
  value = "${element(aws_instance.my-test-instance.*.id, 1)}"
}

output "instance2_id" {
  value = "${element(aws_instance.my-test-instance.*.id, 2)}"
}