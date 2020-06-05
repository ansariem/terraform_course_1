#provider
provider "aws" {
  region = "${var.region}"
  #  region = "us-east-2"
}
#data "aws_availability_zone" "available" {}
##This is for fetching the latest image from the awsmarketplaces which is not recommaned in production env. Provider code will get from the official poratal  of OS provoder
data "aws_ami" "centos" {
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

#public key information and file location
resource "aws_key_pair" "ansari-key" {
  key_name   = "ansari-deployer-key"
  public_key = "${file(var.my_public_key)}"

}

# *.tpl for for install and configure steps after instence spin up

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

#Create the instances

resource "aws_instance" "my-test-instance" {
  count                  = 2
  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.ansari-key.id}"
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id              = "${element(var.subnets, count.index)}"
  user_data              = "${data.template_file.init.rendered}"

  #Instnace tags and count.index refer the above count for no of instance
  tags = {
    Name = "my-instance-${count.index + 1}"
  }
}

