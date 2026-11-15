# Use this data source to get the ID of an available OpenStack router.
#
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_router_v2
#
data "openstack_networking_router_v2" "default" {
  name = var.router_name
}
