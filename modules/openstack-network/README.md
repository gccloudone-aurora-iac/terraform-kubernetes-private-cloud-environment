# terraform-private-cloud-openstack-network

This module configures networking for Open Stack in GC Private Cloud.

<!-- BEGIN_TF_DOCS -->
## 📋 Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | >= 3.0.0, < 4.0.0 |

## 🔌 Providers

| Name | Version |
|------|---------|
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | >= 3.0.0, < 4.0.0 |

## 🧩 Modules

No modules.

## 🗂️ Resources

| Name | Type |
|------|------|
| [openstack_networking_network_v2.this](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_network_v2) | resource |
| [openstack_networking_subnet_v2.v4](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2) | resource |
| [openstack_networking_subnet_v2.v6](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_subnet_v2) | resource |

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_dhcp"></a> [enable\_dhcp](#input\_enable\_dhcp) | Whether to enable DHCP on the IPv4 subnets. | `bool` | `true` | no |
| <a name="input_ipv6_address_mode"></a> [ipv6\_address\_mode](#input\_ipv6\_address\_mode) | How IPv6 addresses are assigned on the IPv6 subnets. One of dhcpv6-stateful, dhcpv6-stateless or slaac. | `string` | `"dhcpv6-stateless"` | no |
| <a name="input_ipv6_ra_mode"></a> [ipv6\_ra\_mode](#input\_ipv6\_ra\_mode) | How IPv6 router advertisements are sent on the IPv6 subnets. One of dhcpv6-stateful, dhcpv6-stateless or slaac. | `string` | `"dhcpv6-stateless"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the network zone. | `string` | n/a | yes |
| <a name="input_nameservers_v4"></a> [nameservers\_v4](#input\_nameservers\_v4) | A list of IPv4 DNS servers to advertise to clients on the IPv4 subnets. | `list(string)` | `[]` | no |
| <a name="input_nameservers_v6"></a> [nameservers\_v6](#input\_nameservers\_v6) | A list of IPv6 DNS servers to advertise to clients on the IPv6 subnets. | `list(string)` | `[]` | no |
| <a name="input_no_gateway"></a> [no\_gateway](#input\_no\_gateway) | Whether to create the subnets without a gateway. When false, the gateway is the first address in each prefix and the allocation pool starts at the second. | `bool` | `false` | no |
| <a name="input_prefixes_v4"></a> [prefixes\_v4](#input\_prefixes\_v4) | IPv4 network prefixes for the network. | `list(string)` | `[]` | no |
| <a name="input_prefixes_v6"></a> [prefixes\_v6](#input\_prefixes\_v6) | IPv6 network prefixes for the network. | `list(string)` | `[]` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the OpenStack network. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | A map of the network's subnet IDs, keyed by the CIDR prefix of each subnet. |
<!-- END_TF_DOCS -->
