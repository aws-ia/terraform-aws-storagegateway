terraform {
  required_version = ">=1.2.0"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">=1.25.0"
    }
  }
}
