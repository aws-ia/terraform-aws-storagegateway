output "public_ip" {
  value       = try(aws_eip.ip[0].public_ip, "No public IP created")
  description = "The Public IP address of the created Elastic IP."
  sensitive   = true
}

output "private_ip" {
  value       = aws_instance.ec2_sgw.private_ip
  description = "The Private IP address of the Storage Gateway on EC2"
}