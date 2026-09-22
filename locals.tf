locals {
  tags = merge(var.tags, { ModuleName = "terraform-kubernetes-private-cloud-environment" }, { ModuleVersion = "v0.0.1" })
}
