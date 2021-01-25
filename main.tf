# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

resource "random_string" "random" {
  length = 4
  special = false
  upper  = false
}

resource "tls_private_key" "cks" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Write private key out to a file
resource "local_file" "private_key" {
  filename = "sshkey.pem"
  file_permission   = 0600
  sensitive_content = tls_private_key.cks.private_key_pem
}

resource "aws_key_pair" "key" {
  key_name   = "${var.deployname}.${random_string.random.result}"
  public_key = tls_private_key.cks.public_key_openssh
}


resource "random_string" "token1" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token2" {
  length  = 16
  special = false
  upper   = false
}

locals {
  token = join(".", [random_string.token1.result, random_string.token2.result])
}




resource "aws_instance" "docker_host" {
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = var.amitype
  vpc_security_group_ids = [aws_security_group.docker_host.id]
  iam_instance_profile   = aws_iam_instance_profile.dockerhost_profile.name
  key_name               = aws_key_pair.key.key_name
  private_ip             = "10.152.2.50"
  subnet_id              = module.vpc.public_subnets[0]
  #user_data              = file("files/node1.sh")
  user_data              = data.template_file.node1.rendered
  tags = {
    Name = "${var.deployname}.${random_string.random.result}"
    Owner = format("%s",data.external.whoiamuser.result.iam_user)
  }

  root_block_device {
    volume_size = var.volsize
    encrypted   = true
  }
  

}

resource "null_resource" "previous" {}


resource "time_sleep" "wait_3_minutes" {
  depends_on = [null_resource.previous]

  create_duration = "180s"
}

resource "aws_instance" "docker_host2" {
  depends_on             = [time_sleep.wait_3_minutes]
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = var.amitype
  vpc_security_group_ids = [aws_security_group.docker_host.id]
  iam_instance_profile   = aws_iam_instance_profile.dockerhost_profile.name
  key_name               = aws_key_pair.key.key_name
  private_ip             = "10.152.2.60"
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = data.template_file.node2.rendered
  tags = {
    Name = "${var.deployname}2.${random_string.random.result}"
    Owner = format("%s",data.external.whoiamuser.result.iam_user)
  }

  root_block_device {
    volume_size = var.volsize
    encrypted   = true
  }
  
# on mac os x, use: `sed -i '' -e`; on linux, use simply `sed -i`
  provisioner "local-exec" {
    command = "chmod 0600 sshkey.pem ; scp -i sshkey.pem -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  ubuntu@${aws_eip.ip_docker.public_ip}:.kube/config kube.config >/dev/null 2>&1 && sed -i 's/10.152.2.50/${aws_eip.ip_docker.public_ip}/g' kube.config"
  }

}

resource "aws_eip" "ip_docker" {
  vpc      = true
  instance = aws_instance.docker_host.id 
}

