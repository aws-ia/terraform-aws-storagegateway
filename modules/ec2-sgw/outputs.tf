output "public_ip" {
  value       = aws_eip.ip.public_ip
  description = "The Public IP address of the created Elastic IP."
}


