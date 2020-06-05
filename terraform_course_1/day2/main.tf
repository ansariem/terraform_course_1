#provider
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

data "aws_availability_zones" "available" {}
# VPC Creation
resource "aws_vpc" "ansari_main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my-ansari-vpc"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "ansari_gw" {
  vpc_id = "${aws_vpc.ansari_main.id}"

  tags = {
    Name = "my-ansari-igw"
  }
}

# NAt gateway

/*resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"

  tags = {
    Name = "gw NAT"
  }
}*/

/*resource "aws_nat_gateway" "ec27332aa6" {
  subnet_id     = "subnet-0afc59073f22a05df"
  allocation_id = "eipalloc-0b4ca34475ecd69d1"
}*/

# Creating Public route table
resource "aws_route_table" "ansari_public_route" {
  vpc_id = "${aws_vpc.ansari_main.id}"

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = "${aws_internet_gateway.ansari_gw.id}"
  }

  tags = {
    Name = "my_ansari_public_route"
  }
}
#Create the private route.
resource "aws_default_route_table" "ansari_private_route" {
  default_route_table_id = "${aws_vpc.ansari_main.default_route_table_id}"

  tags = {
    Name = "my-Ansari-private-route-table"
  }
}

#Public Subnet count.index (count =0 )it will use  only use 2 availability zone

resource "aws_subnet" "ansari_public_subnet" {
  count                   = 2
  cidr_block              = "${var.public_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.ansari_main.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "my-ansari-public-subnet.${count.index + 1}"
  }
}

#Public Private count.index (count =0 )it will use only use 2 availability zone

resource "aws_subnet" "ansari_private_subnet" {
  count                   = 2
  cidr_block              = "${var.private_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.ansari_main.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "my-ansari-private-subnet.${count.index + 1}"
  }
}


# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  route_table_id = "${aws_route_table.ansari_public_route.id}"
  subnet_id      = "${aws_subnet.ansari_public_subnet.*.id[count.index]}"
  depends_on     = ["aws_route_table.ansari_public_route", "aws_subnet.ansari_public_subnet"]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  route_table_id = "${aws_default_route_table.ansari_private_route.id}"
  subnet_id      = "${aws_subnet.ansari_private_subnet.*.id[count.index]}"
  depends_on     = ["aws_default_route_table.ansari_private_route", "aws_subnet.ansari_private_subnet"]
}


resource "aws_security_group" "my-ansari-sg" {
  name   = "my-ansari-sg"
  vpc_id = "${aws_vpc.ansari_main.id}"
}

resource "aws_security_group_rule" "allow-ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my-ansari-sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-outbound" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.my-ansari-sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
