# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Configure the AWS Provider
provider "awscc" {
  region = var.region
}

provider "vsphere" {
  allow_unverified_ssl = var.allow_unverified_ssl
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
}
