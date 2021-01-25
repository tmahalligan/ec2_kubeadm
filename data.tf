data "external" "myip" {
  program = ["/bin/bash" , "files/whatismyip.sh"]
}

#data "http" "myip" {
#  url = "http://ipv4.icanhazip.com"
#}


data "external" "whoiamuser" {
  program = ["/bin/bash" , "files/whoami.sh"]
}

data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ami" "ubuntu_linux" {
  most_recent = true

  owners = var.amiowner

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*",
    ]
  }
}

data "template_file" "node1" {
  template = file("files/node1.sh")
  vars = {
    token = local.token
    KUBE_VERSION = "1.19.3"
  }
}

data "template_file" "node2" {
  template = file("files/node2.sh")
  vars = {
    token = local.token
    KUBE_VERSION = "1.19.3"
  }
}