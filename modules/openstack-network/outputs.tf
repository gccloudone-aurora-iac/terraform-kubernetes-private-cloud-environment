output "id" {
  description = "The ID of the OpenStack network."
  value       = openstack_networking_network_v2.this.id
}

output "subnet_ids" {
  description = "A map of the network's subnet IDs, keyed by the CIDR prefix of each subnet."
  value = merge(
    { for prefix, subnet in openstack_networking_subnet_v2.v4 : prefix => subnet.id },
  { for prefix, subnet in openstack_networking_subnet_v2.v6 : prefix => subnet.id })
}
