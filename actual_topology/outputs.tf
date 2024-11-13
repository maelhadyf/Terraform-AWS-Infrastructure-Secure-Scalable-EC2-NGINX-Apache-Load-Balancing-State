output "external_lb_dns" {
  value = aws_lb.external.dns_name
}

output "internal_lb_dns" {
  value = aws_lb.internal.dns_name
}

output "public_instance_ips" {
  value = aws_instance.public[*].public_ip
}

output "private_instance_ips" {
  value = aws_instance.private[*].private_ip
}
