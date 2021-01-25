output "External_IP" {
  value = aws_eip.ip_docker.public_ip
}

output "token" {
 value = local.token
}
