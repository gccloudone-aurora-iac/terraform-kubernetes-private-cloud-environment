###########################
### OpenStack Resources ###
###########################

variable "application_credential_id" {
  description = "Application Credential ID for authentication with OpenStack."
  type        = string
}

variable "application_credential_secret" {
  description = "Application Credential Secret for authentication with OpenStack."
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
  description = "OpenStack Authentication URL"
  type        = string
}

variable "region" {
  description = "OpenStack region where to deploy the cluster."
  type        = string
}

variable "availability_zone" {
  description = "OpenStack Availability Zone where to deploy the cluster."
  type        = string

  default = null
}

variable "network_id" {
  description = "Network ID of the OpenStack network where to deploy the cluster."
  type        = string
}

variable "tags" {
  description = "Tags to assign to the OpenStack resources."
  type        = map(string)
  default     = {}
}

#########################
### Rancher Resources ###
#########################

variable "name" {
  description = "Name of the cluster."
  type        = string
}

variable "image_name" {
  description = "Name of the image for the nodes."
  type        = string

  default = "debian-13-trixie"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to install."
  type        = string

  default = "v1.36.3+rke2r1"
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

variable "network_plugin" {
  description = "Network plugin to use for the cluster."
  type        = string

  default = "cilium"

  validation {
    condition     = contains(["none", "cilium"], var.network_plugin)
    error_message = "Valid network plugins are: none, cilium"
  }
}

variable "cluster_cidr" {
  description = "CIDR of the cluster."

  type    = list(string)
  default = ["192.168.0.0/16"]
}

variable "service_cidr" {
  description = "Cluster service CIDRs."

  type    = list(string)
  default = ["172.16.0.0/20"]
}

variable "control_pool" {
  description = "Configuration for the control pool."

  type = object({
    name    = optional(string, "control")
    flavour = optional(string, "g4v-16")
    count   = optional(number, 1)
    labels  = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = optional(string, "NoExecute")
    })), [])
    security_groups = optional(list(string), ["default"])
    volume_type     = optional(string, "performance")
    volume_size     = optional(number, 60)
    roles           = optional(list(string), ["etcd", "control"])
    image_name      = optional(string)
    user_data       = optional(string)
    network_id      = optional(string)
  })

  default = {}
}

variable "worker_pool" {
  description = "Configuration for the worker pool."

  type = object({
    name    = optional(string, "worker")
    flavour = optional(string, "g4v-16")
    count   = optional(number, 1)
    labels  = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = optional(string, "NoExecute")
    })), [])
    security_groups = optional(list(string), ["default"])
    volume_type     = optional(string, "performance")
    volume_size     = optional(number, 60)
    roles           = optional(list(string), ["worker"])
    image_name      = optional(string)
    user_data       = optional(string)
    network_id      = optional(string)
  })

  default = {}
}

variable "additional_pools" {
  description = "List of pools for the cluster."

  type = list(object({
    name    = string
    roles   = optional(list(string), ["worker"])
    flavour = optional(string, "g4v-16")
    count   = optional(number, 1)
    labels  = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = optional(string, "NoExecute")
    })), [])
    security_groups = optional(list(string), ["default"])
    volume_type     = optional(string, "performance")
    volume_size     = optional(number, 60)
    image_name      = optional(string)
    user_data       = optional(string)
    network_id      = optional(string)
  }))

  default = []
}

#######################
### Global Registry ###
#######################

variable "global_registry" {
  description = "Global registry for system resources."
  type        = string

  default = "artifacts-artefacts.devops.cloud-nuage.canada.ca"
}

variable "global_registry_auth_secret" {
  description = "Secret name containing global registry authentication for system resources."
  type        = string

  default = "gcsa"
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
