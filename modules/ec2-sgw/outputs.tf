output "public_ip" {
  value       = aws_eip.ip.public_ip
  description = "The Public IP address of the created Elastic IP."
}

output "private_ip" {
  value       = aws_instance.ec2-sgw.private_ip
  description = "The Private IP address of the Storage Gateway EC2 appliance"
}