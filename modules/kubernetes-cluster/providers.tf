# Providers

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 8.2"
    }
  }
}
