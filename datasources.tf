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
      "bitnami-jenkins-*"
    ]
  }

  owners = [
    "979382823631"
  ]
}
