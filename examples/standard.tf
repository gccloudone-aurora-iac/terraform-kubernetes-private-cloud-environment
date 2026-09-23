####################
### Local Values ###
####################

locals {
  # The Rancher cluster name. Also the name of the Rancher cloud credential and
  # the prefix of every machine config, so keep it short and stable.
  cluster_name = ""

  # Rancher user IDs, not email addresses or Entra ID object IDs. Each one gets a
  # `cluster-owner` binding named `crtb-cluster-owner-<id>`. Find them in the
  # Rancher UI under Users & Authentication.
  cluster_owners = []

  # A pre-existing OpenStack router, looked up by name. This module never creates
  # a router — it only attaches its subnets to one.
  router_name = ""

  # Resolvers advertised to every subnet this module creates.
  dns_nameservers = []

  tags = {
    DataClassification      = "Unclassified"
    wid                     = "00001"
    environment             = "dev"
    PrimaryTechnicalContact = "full.name@ssc-spc.gc.ca"
    PrimaryProjectContact   = "full.name@ssc-spc.gc.ca"
  }
}

#################
### Variables ###
#################

# Credentials are kept out of the configuration. Copy
# terraform.tfvars.example to terraform.tfvars and fill it in; that file is
# gitignored.

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

variable "rancher_api_url" {
  description = "The Rancher API URL to connect to."
  type        = string
}

variable "rancher_token" {
  description = "The Rancher bearer token to use to authenticate with Rancher."
  type        = string

  sensitive = true
}

#################
### Providers ###
#################

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0, < 4.0.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 8.2"
    }
  }
}

# Rancher owns the cluster; the module talks to it through this provider.
#
provider "rancher2" {
  api_url   = var.rancher_api_url
  token_key = var.rancher_token
}

# The OpenStack provider authenticates from a named cloud in clouds.yaml.
#
# Note the split: the application credential passed to the module below is a
# separate thing entirely, and is never used to configure this provider. The
# module embeds it in the Rancher machine config and in the cluster's generated
# additional_manifest, so the nodes and the in-cluster cloud provider / CSI
# driver can call OpenStack themselves. Rotating that credential is a change to
# live cluster configuration, not just to Terraform's own auth.
#
provider "openstack" {
  cloud = "private-cloud"
}

####################
### Data Sources ###
####################

# Use this data source to get information about the currently scoped auth.
#
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/identity_auth_scope_v3
#
data "openstack_identity_auth_scope_v3" "this" {
  name = "current_scope"
}

#################################
### Aurora Environment Module ###
#################################

# Manages the Aurora Environment for GC Private Cloud.
#
# ../
#
module "aurora" {
  source = "../"

  #################
  ### OpenStack ###
  #################

  openstack_application_credential_id     = var.openstack_application_credential_id
  openstack_application_credential_secret = var.openstack_application_credential_secret
  openstack_domain_id                     = var.openstack_domain_id
  openstack_project_id                    = var.openstack_project_id
  openstack_auth_url                      = var.openstack_auth_url
  openstack_region                        = var.openstack_region

  ###############
  ### Network ###
  ###############

  # Unlike the Azure environment module, there is no supplied-network path: this
  # module always creates its own networking. Four zones are created, each an
  # OpenStack network with its subnets, each attached to `router_name`.
  #
  # All four keys are required. Every zone's module block reads
  # var.network_prefixes["<zone>"] directly, so a missing key fails at plan time.
  # The values below are the module's own defaults, restated here to show the
  # shape; omit the argument entirely to accept them, as the live deployment
  # does.
  #
  # prefixes_v6 is accepted and the underlying module fully supports IPv6
  # subnets, but every call site currently hard-codes an empty v6 list, so
  # setting it here has no effect yet.
  network_prefixes = {
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

  dns_nameservers = local.dns_nameservers

  router_name = local.router_name

  ##################
  ### Kubernetes ###
  ##################

  # An RKE2 version string as Rancher reports it, not a bare Kubernetes version:
  # the `+rke2r<n>` suffix and the leading `v` are both required.
  kubernetes_version = "v1.34.1+rke2r1"

  cluster_name      = local.cluster_name
  cluster_operators = local.cluster_owners

  # Node pools are not an input. They are declared inside the module in
  # infrastructure.tf — `system` (etcd + control plane), `general` (worker) and a
  # tainted `gateway` worker pool — each pinned to the matching network zone.
  # Changing pool shape means editing the module, not this file.

  tags = local.tags

  # Both providers must be passed explicitly. The module declares
  # required_providers but configures nothing itself.
  providers = {
    rancher2  = rancher2,
    openstack = openstack,
  }
}

###############
### Outputs ###
###############

output "current_project_id" {
  description = "The ID of the OpenStack project the configuration is authenticated against."
  value       = data.openstack_identity_auth_scope_v3.this.project_id
}
