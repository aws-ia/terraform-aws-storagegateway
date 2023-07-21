terraform {
  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.24.0"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">=2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure the AWS Provider
provider "awscc" {
  region = var.aws_region
}