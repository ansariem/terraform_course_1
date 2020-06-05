#provider
provider "aws" {
  region = "us-east-2"
}

#module we can use it for one more vpc if required.
module "vpc" {
  region        = "us-east-2"
  source        = "./vpc"
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

#module we can use it for ec2 instance.
module "ec2" {
  source         = "./ec2"
  region         = "us-east-2"
  my_public_key  = "/terraform/sshkey/id_rsa.pub"
  instance_type  = "t2.micro"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.subnets}"
}

module "alb" {
  source       = "./alb"
  vpc_id       = "${module.vpc.vpc_id}"
  instance1_id = "${module.ec2.instance1_id}"
  instance2_id = "${module.ec2.instance2_id}"
  subnet1      = "${module.vpc.subnet1}"
  subnet2      = "${module.vpc.subnet2}"
}

/*module "autoscale" {
  source       = "./auto_scaling"
  vpc_id       = "${module.vpc.vpc_id}"
  subnet1      = "${module.vpc.subnet1}"
  subnet2      = "${module.vpc.subnet2}"
  target_group_arn = "${module.autoscale}"
}*/