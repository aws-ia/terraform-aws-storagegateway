variable "share_name" {
  description = "Name of the smb file share"
  type        = string
}

variable "gateway_arn" {
  type        = string
  description = "Storage Gateway ARN"
}

variable "bucket_arn" {
  type        = string
  description = "Storage Gateway ARN"
}

variable "storage_class" {
  type        = string
  description = "Storage Gateway ARN"
  default     = "S3_STANDARD"
}

variable "role_arn" {
  type        = string
  description = "The ARN of the AWS Identity and Access Management (IAM) role that a file gateway assumes when it accesses the underlying storage. "
}

variable "admin_user_list" {
  type        = list(any)
  description = "A list of users in the Active Directory that have admin access to the file share."
  default     = ["Domain Admins"]
}

variable "log_group_arn" {
  type        = string
  description = "Cloudwatch Log Group ARN for audit logs"
}

variable "cache_timout" {
  type        = number
  description = "Cache stale timeout for automated cache refresh in seconds. Default is set to 1 hour (3600 seconds) can be changed to as low as 5 minutes (300 seconds)"
  default     = "3600"
}
