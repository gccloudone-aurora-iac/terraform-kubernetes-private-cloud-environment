###########################
### OpenStack Resources ###
###########################

variable "name" {
  description = "Name of the network zone."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Only a-z, A-Z, 0-9 and hyphen (-) are allowed."
  }

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 20
    error_message = "Must be 1 to 20 characters long."
  }
}

variable "prefixes_v4" {
  description = "IPv4 network prefixes for the network."
  type        = list(string)

  default = []
}

variable "prefixes_v6" {
  description = "IPv6 network prefixes for the network."
  type        = list(string)

  default = []
}

variable "no_gateway" {
  description = "Whether to create the subnets without a gateway. When false, the gateway is the first address in each prefix and the allocation pool starts at the second."
  type        = bool

  default = false
}

variable "enable_dhcp" {
  description = "Whether to enable DHCP on the IPv4 subnets."
  type        = bool

  default = true
}

variable "ipv6_address_mode" {
  description = "How IPv6 addresses are assigned on the IPv6 subnets. One of dhcpv6-stateful, dhcpv6-stateless or slaac."
  type        = string

  default  = "dhcpv6-stateless"
  nullable = true
}

variable "ipv6_ra_mode" {
  description = "How IPv6 router advertisements are sent on the IPv6 subnets. One of dhcpv6-stateful, dhcpv6-stateless or slaac."
  type        = string

  default  = "dhcpv6-stateless"
  nullable = true
}

variable "nameservers_v4" {
  description = "A list of IPv4 DNS servers to advertise to clients on the IPv4 subnets."
  type        = list(string)

  default = []
}

variable "nameservers_v6" {
  description = "A list of IPv6 DNS servers to advertise to clients on the IPv6 subnets."
  type        = list(string)

  default = []
}
