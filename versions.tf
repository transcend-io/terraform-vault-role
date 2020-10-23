terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }
  required_version = ">= 0.13"
}
