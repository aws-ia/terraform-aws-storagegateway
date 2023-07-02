output "storage_gateway" {
  value       = aws_storagegateway_gateway.mysgw
  description = "Storage Gateway Module"
  sensitive   = true
}

output "storage_gateway_name" {
  value       = aws_storagegateway_gateway.mysgw.gateway_name
  description = "Storage Gateway Name"
}