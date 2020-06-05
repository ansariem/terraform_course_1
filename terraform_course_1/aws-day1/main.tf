# Create a new instance of the latest Centos 7.x on an
# t2.micro node with an AWS Tag naming it "Jenkins"
provider "aws" {
  access_key = "${var.access_key}"
  #access_key = "${file("access_key")}"
  secret_key = "${var.secret_key}"
  #secret_key = "${file("secret_key")}"
  region     = "${var.region}"
}

#Create the instances

resource "aws_instance" "my-day1-instance" {
  count         = 1
  ami           = "${var.ami}"
  instance_type = "t2.micro"
  key_name      = "${var.mykey}"
  #user_data = "${file("install_devops_tools.sh")}"

  #Instnace tags and count.index refer the above count for no of instance
  tags = {
    Name = "my-day1-${count.index + 1}"
  }
}

