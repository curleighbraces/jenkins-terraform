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
