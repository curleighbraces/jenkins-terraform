provider "aws" {
  region = "eu-west-1"
}

variable "jenkins_home" {
  type = "string"
  default = "/opt/bitnami/apps/jenkins/jenkins_home/"
}

data "terraform_remote_state" "aws-core" {
  backend = "s3"
  config {
    bucket = "aws-core"
    key = "aws-core"
    region = "eu-west-1"
  }
}


data "aws_ami" "jenkins" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "bitnami-jenkins-*"]
  }

  owners = [
    "979382823631"
  ]
}


resource "aws_vpc" "jenkins" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "Jenkins"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.jenkins.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.jenkins.id}"

  tags {
    Name = "jenkins"
  }
}

resource "aws_security_group" "web" {
  name = "vpc_web"
  description = "Allow incoming HTTP connections."

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.jenkins.id}"
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.jenkins.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
    Name = "Public"
  }
}


resource "aws_route53_record" "jenkins-ns" {
  zone_id = "${data.terraform_remote_state.aws-core.core_zone_id}"
  name = "jenkins.curleighbraces.com"
  type = "A"
  ttl = "30"

  records = [
    "${aws_instance.jenkins.public_ip}"
  ]
}

resource "aws_instance" "jenkins" {
  ami = "${data.aws_ami.jenkins.id}"
  instance_type = "t2.micro"
  key_name = "curleigh-braces"

  subnet_id = "${aws_subnet.public.id}"


  connection {
    user = "bitnami"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir ${var.jenkins_home}init.groovy.d/",
      "sudo chown bitnami:bitnami ${var.jenkins_home}init.groovy.d/"
    ]
  }

  provisioner "file" {
    source = "bootstrap/managePlugins.groovy"
    destination = "${var.jenkins_home}init.groovy.d/managePlugins.groovy"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chown -R tomcat:tomcat ${var.jenkins_home}init.groovy.d/"
    ]
  }

  tags {
    Name = "Jenkins"
  }
}