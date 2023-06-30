output "storage_gateway" {
  value       = aws_storagegateway_gateway.mysgw.gateway_name
  description = "Storage Gateway Name"
}