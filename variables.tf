###########################
### OpenStack Resources ###
###########################

variable "openstack_application_credential_id" {
  description = "Application Credential ID used by Rancher to provision on OpenStack."
  type        = string
}

variable "openstack_application_credential_secret" {
  description = "Application Credential Secret used by Rancher to provision on OpenStack."
  type        = string

  sensitive = true
}

variable "openstack_domain_id" {
  description = "Domain ID of the OpenStack tenant where to deploy the cluster."
  type        = string
}

variable "openstack_project_id" {
  description = "Project ID of the OpenStack project where to deploy the cluster."
  type        = string
}

variable "openstack_auth_url" {
  description = "OpenStack Authentication URL."
  type        = string
}

variable "openstack_region" {
  description = "OpenStack region where to deploy the cluster."
  type        = string
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

variable "cluster_name" {
  description = "The name of the Rancher Cluster."
  type        = string
}

variable "cluster_operators" {
  description = "A list of Rancher user IDs to indicate the operators of the cluster."
  type        = list(string)
}

##################
### Networking ###
##################

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

variable "router_name" {
  description = "The name of the pre-existing OpenStack router to attach each created subnet to."
  type        = string
}
