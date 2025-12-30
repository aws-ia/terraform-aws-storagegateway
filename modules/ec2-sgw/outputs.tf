output "public_ip" {
  value       = aws_eip.ip.public_ip
  description = "The Public IP address of the created Elastic IP."
  sensitive   = true
}

output "private_ip" {
  value       = aws_instance.ec2_sgw.private_ip
  description = "The Private IP address of the Storage Gateway on EC2"
}

output "ami_id" {
  value       = data.aws_ssm_parameter.sgw_ami.value
  description = "The AMI ID used for the Storage Gateway EC2 instance"
}