#provider
provider "aws" {
  region = "us-east-2"
}

#module we can use it for one more vpc if required.
module "vpc" {
  source        = "./vpc"
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

#module we can use it for ec2 instance.
module "ec2" {
  source         = "./ec2"
  my_public_key  = "/terraform/sshkey/id_rsa.pub"
  instance_type  = "t2.micro"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.subnets}"
}
