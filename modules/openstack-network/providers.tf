# Providers

terraform {
  required_version = ">= 1.9"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0, < 4.0.0"
    }
  }
}
