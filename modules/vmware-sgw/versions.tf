terraform {
  required_version = ">= 1.5.7"
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.4.0"
    }
  }
}
