output "Webserver_public_IP" {
  value = aws_instance.Ubuntu_Web.public_ip
}

output "Webserver_private_IP" {
  value = aws_instance.Ubuntu_Web.private_ip
}

output "DB_public_IP" {
  value = aws_instance.Amazon_Linux_DB.public_ip
}

output "DB_private_IP" {
  value = aws_instance.Amazon_Linux_DB.private_ip
}
