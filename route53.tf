resource "aws_route53_record" "jenkins-ns" {
  zone_id = "${data.terraform_remote_state.aws-core.core_zone_id}"
  name = "jenkins.curleighbraces.com"
  type = "A"
  ttl = "30"

  records = [
    "${aws_instance.jenkins.public_ip}"
  ]
}
