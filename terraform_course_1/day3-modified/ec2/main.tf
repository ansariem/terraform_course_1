#provider
provider "aws" {
  region = "us-east-2"
}
#data "aws_availability_zone" "available" {}

data "aws_ami" "centOS" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

resource "aws_key_pair" "ansari-key" {
  key_name = "ansari-deployer-key"
  ##key_name = "Ansari-key"
  public_key = "${file(var.my_public_key)}"

}


data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}
#Create the instances

resource "aws_instance" "my-test-instance" {
  count                  = 2
  ami                    = "${data.aws_ami.centOS.id}"
#  availability_zone = "${var.availability-zones[count.index]}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.ansari-key.id}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index)}"
  user_data              = "${data.template_file.init.rendered}"

  tags = {
    Name = "my-instance-${count.index + 1}"
  }
}

