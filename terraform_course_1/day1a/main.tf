#provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}


resource "aws_key_pair" "ansari-deployer" {
   key_name = "ansari-deployer-key"
  #key_name = "ec2-test-key"
   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkQg9XPzFiVc6U0hnZMUia3QEijQgku5U+vxvO3k6azMdpPLo4BnbVJDw0XTCiiw8SOjMM0T//dNdTNKpKNRCkSrS5YNdD3KMFkCXMiu3oGWcLha9X5gjPV3UsYuTNidRaaDKcQDBZ5qyXn+/8v8eTr3C4vESeVhahjD1Wndih0hBS6ZsqSyrmgLwqu59C2z8AELQGKRcKiHGm9u1EqEtf3YKdz9lm4oYFdewoxgi051p2XAq/2SY9dZHwEZc0aNL4Gm3hVIzLYIVqm0dfg7fG2R2e9c4Cn3slOYK75eRKwRcr+O3z8M9Kp0Ue7JHMUtdqkDoTwtnHBYFQziKsjdP3 ansaryem@gmail.com"
}

resource "aws_security_group" "ansari-sg" {
  name        = "ansari-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    # ssh (change to whatever ports you need)
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/24"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/24"]
    #    prefix_list_ids = ["pl-12c4e678"]
  }
}

resource "aws_internet_gateway" "mygw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "main ig"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_instance" "ec2_ansari" {
  ami                    = "ami-0dacb0c129b49f529"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.ansari-sg.id}"]
  key_name               = "${aws_key_pair.ansari-deployer.id}"

  tags = {
    Name = "ansari-world"
  }
}
