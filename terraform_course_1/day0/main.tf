#provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}


resource "aws_instance" "web" {
  ami                    = "ami-0d5d9d301c853a04a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  user_data              = <<-EOF
  #!/bin/bash
  sudo apt update
  sudo apt install -y apache2
  echo " This is conming from terraform" >> /var/www/html/index.html
  sudo ufw allow 'Apache'
  sudo systemctl start apache2
  sudo systemctl enable apache2
  EOF

  tags = {
    Name = "Ansari-terraform-VM"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = ["0.0.0.0/0"]
  }

}
