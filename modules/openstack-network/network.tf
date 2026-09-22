# Manages a V2 Neutron network resource within OpenStack.
#
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_network_v2
#
resource "openstack_networking_network_v2" "this" {
  name = var.name
}

# Manages a V2 Neutron subnet resource within OpenStack.
#
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2
#
resource "openstack_networking_subnet_v2" "v4" {
  for_each = toset(var.prefixes_v4)

  name            = "${var.name}-${each.value}"
  network_id      = openstack_networking_network_v2.this.id
  ip_version      = 4
  cidr            = each.value
  no_gateway      = var.no_gateway == true ? var.no_gateway : null
  gateway_ip      = var.no_gateway == false ? cidrhost(each.value, 1) : null
  enable_dhcp     = var.enable_dhcp
  dns_nameservers = var.nameservers_v4

  allocation_pool {
    start = cidrhost(each.value, var.no_gateway == true ? 1 : 2)
    end   = cidrhost(each.value, -2)
  }
}

# Manages a V2 Neutron subnet resource within OpenStack.
#
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2
#
resource "openstack_networking_subnet_v2" "v6" {
  for_each = toset(var.prefixes_v6)

  name       = "${var.name}-${each.value}"
  network_id = openstack_networking_network_v2.this.id
  ip_version = 6
  cidr       = each.value

  no_gateway      = var.no_gateway == true ? var.no_gateway : null
  gateway_ip      = var.no_gateway == false ? cidrhost(each.value, 1) : null
  dns_nameservers = var.nameservers_v6

  ipv6_address_mode = var.ipv6_address_mode
  ipv6_ra_mode      = var.ipv6_ra_mode

  allocation_pool {
    start = cidrhost(each.value, var.no_gateway == true ? 1 : 2)
    end   = cidrhost(each.value, -1)
  }
}
