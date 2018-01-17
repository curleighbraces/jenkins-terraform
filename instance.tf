
locals {
  jenkins_home = "/opt/bitnami/apps/jenkins/jenkins_home/"
}

data "template_file" "groovy-manage-plugins" {
  template = "${file("templates/managePlugins.groovy")}"
}

data "template_file" "jenkins-bootstrap" {
  template = "${file("templates/jenkins-bootstrap.sh")}"

  vars {
    jenkins_home = "${local.jenkins_home}"
    groovy_manage_plugins = "${data.template_file.groovy-manage-plugins.rendered}"
  }
}

resource "aws_instance" "jenkins" {
  ami = "ami-0bdc4e72"
  instance_type = "t2.micro"
  key_name = "curleigh-braces"

  subnet_id = "${aws_subnet.public.id}"

  security_groups = ["${aws_security_group.jenkins.id}"]

  user_data = "${data.template_file.jenkins-bootstrap.rendered}"

  connection {
    user = "bitnami"
  }


  tags {
    Name = "Jenkins"
  }
}