###########################
### OpenStack Resources ###
###########################

variable "application_credential_id" {
  description = "Application Credential ID used by Rancher to provision on OpenStack."
  type        = string
}

variable "application_credential_secret" {
  description = "Application Credential Secret used by Rancher to provision on OpenStack."
  type        = string

  sensitive = true
}

variable "domain_id" {
  description = "Domain ID of the OpenStack tenant where to deploy the cluster."
  type        = string
}

variable "project_id" {
  description = "Project ID of the OpenStack project where to deploy the cluster."
  type        = string
}

variable "auth_url" {
  description = "OpenStack Authentication URL."
  type        = string
}

variable "region" {
  description = "OpenStack region where to deploy the cluster."
  type        = string
}

variable "availability_zone" {
  description = "OpenStack availability zone for the nodes. Null preserves the existing region-name fallback."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to assign to the OpenStack resources."
  type        = map(string)
  default     = {}
}

######################################
### Rancher Cluster Infrastructure ###
######################################

variable "kubernetes_version" {
  description = "The RKE2 version used by the control plane and the default version for the agent nodes, as Rancher reports it (e.g. v1.34.1+rke2r1)."
  type        = string
}

variable "openstack_chart_versions" {
  description = "Exact Helm chart versions for the OpenStack cloud controller manager and Cinder CSI driver."
  type = object({
    cloud_controller_manager = string
    cinder_csi               = string
  })
  default = {
    cloud_controller_manager = "2.37.1"
    cinder_csi               = "2.37.1"
  }

  validation {
    condition = alltrue([
      for version in values(var.openstack_chart_versions) :
      can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+(-[0-9A-Za-z.-]+)?(\\+[0-9A-Za-z.-]+)?$", version))
    ])
    error_message = "OpenStack Helm chart versions must be exact semantic versions, not version ranges."
  }
}

variable "name" {
  description = "The name of the Rancher Cluster."
  type        = string
}

variable "cluster_operators" {
  description = "A list of Rancher user IDs to indicate the operators of the cluster."
  type        = list(string)
}

variable "image_name" {
  description = "Name of the OpenStack image used for cluster nodes."
  type        = string
  default     = "debian-13-trixie"
}

variable "node_pools" {
  description = "Sizing and security groups for each node pool. Names, roles, labels, taints, and network assignments remain module-managed."
  type = object({
    system = optional(object({
      count           = optional(number, 1)
      flavour         = optional(string, "g4v-16")
      volume_size     = optional(number, 60)
      volume_type     = optional(string, "performance")
      security_groups = optional(list(string), ["default"])
    }), {})
    general = optional(object({
      count           = optional(number, 1)
      flavour         = optional(string, "g4v-16")
      volume_size     = optional(number, 60)
      volume_type     = optional(string, "performance")
      security_groups = optional(list(string), ["default"])
    }), {})
    gateway = optional(object({
      count           = optional(number, 1)
      flavour         = optional(string, "g4v-16")
      volume_size     = optional(number, 60)
      volume_type     = optional(string, "performance")
      security_groups = optional(list(string), ["default"])
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = var.node_pools.system.count >= 1 && alltrue([
      for pool in values(var.node_pools) :
      pool.count >= 0 && floor(pool.count) == pool.count
    ])
    error_message = "Node counts must be non-negative integers, with at least one system node."
  }

  validation {
    condition = alltrue([
      for pool in values(var.node_pools) :
      pool.volume_size > 0 && floor(pool.volume_size) == pool.volume_size
    ])
    error_message = "Node boot volume sizes must be positive integers in GiB."
  }
}

##################
### Networking ###
##################

variable "cluster_cidr" {
  description = "Pod network CIDRs. Choose non-overlapping ranges before deployment; changing an existing cluster is disruptive."
  type        = list(string)
  default     = ["192.168.0.0/16"]

  validation {
    condition     = length(var.cluster_cidr) > 0 && alltrue([for cidr in var.cluster_cidr : can(cidrhost(cidr, 0))])
    error_message = "Pod network CIDRs must be a non-empty list of valid CIDR ranges."
  }
}

variable "service_cidr" {
  description = "Service network CIDRs. Choose non-overlapping ranges before deployment; changing an existing cluster is disruptive."
  type        = list(string)
  default     = ["172.16.0.0/20"]

  validation {
    condition     = length(var.service_cidr) > 0 && alltrue([for cidr in var.service_cidr : can(cidrhost(cidr, 0))])
    error_message = "Service network CIDRs must be a non-empty list of valid CIDR ranges."
  }
}

variable "dns_nameservers" {
  description = "A list of DNS servers to advertise to clients on the network."
  type        = list(string)
}

variable "network_prefixes" {
  description = "Map of network zone names to their corresponding IPv4 and IPv6 prefixes. All four zones (system, general, gateway, loadbalancer) are required."
  type = map(object({
    prefixes_v4 = list(string)
    prefixes_v6 = list(string)
  }))
  default = {
    system = {
      prefixes_v4 = ["10.0.1.0/24"]
      prefixes_v6 = []
    }
    general = {
      prefixes_v4 = ["10.0.2.0/24"]
      prefixes_v6 = []
    }
    gateway = {
      prefixes_v4 = ["10.0.4.0/24"]
      prefixes_v6 = []
    }
    loadbalancer = {
      prefixes_v4 = ["10.0.6.0/24"]
      prefixes_v6 = []
    }
  }
}

variable "network_name" {
  description = "The name of the pre-existing OpenStack network to attach."
  type        = string
}

variable "router_name" {
  description = "The name of the pre-existing OpenStack router to attach."
  type        = string
}

#######################
### Global Registry ###
#######################

variable "global_registry_auth_secret" {
  description = "Name of the pre-existing Rancher registry authentication secret for system images."
  type        = string
  default     = "gcsa"
}

variable "gcsa_username" {
  description = "Username for the GC Secure Artifacts repositories."
  type        = string
}

variable "gcsa_password" {
  description = "Password for the GC Secure Artifacts repositories."
  type        = string
  sensitive   = true
}
