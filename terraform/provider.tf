provider "aws" {
  region = var.default_region
  
  default_tags {
    tags = {
      "ManagedBy" = "Terraform"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.45"
    }
  }
}