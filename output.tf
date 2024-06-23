output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "mysql_instance_private_ip" {
  value = aws_instance.mysql_instance.private_ip
}

output "memcache_instance_private_ip" {
  value = aws_instance.memcache_instance.private_ip
}

output "rabbitmq_instance_private_ip" {
  value = aws_instance.rabbitmq_instance.private_ip
}

output "apptier_instance_private_ip" {
  value = aws_instance.apptier_instance.private_ip
}
