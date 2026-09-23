# Providers

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0, < 4.0.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 8.2"
    }
  }
}
