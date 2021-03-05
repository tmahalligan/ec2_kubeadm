resource "aws_security_group" "docker_host" {
  name_prefix = var.deployname
  vpc_id      = module.vpc.vpc_id

#tfsec:ignore:AWS018
#tfsec:ignore:AWS008


  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [format("%s/%s",data.external.myip.result["internet_ip"],32)]
   # cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #tfsec:ignore:AWS008
    cidr_blocks = ["10.152.2.0/24"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #tfsec:ignore:AWS008
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    #tfsec:ignore:AWS008
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    #tfsec:ignore:AWS009
    cidr_blocks = ["0.0.0.0/0"]
  }
}


