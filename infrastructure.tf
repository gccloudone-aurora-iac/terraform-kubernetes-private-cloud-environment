# Deploys Rancher Kubernetes Cluster and its related infrastructure.
#
# ./modules/kubernetes-cluster
#
module "infrastructure" {
  source = "./modules/kubernetes-cluster"

  depends_on = [
    openstack_networking_router_interface_v2.system,
    openstack_networking_router_interface_v2.general,
    openstack_networking_router_interface_v2.gateway,
    openstack_networking_router_interface_v2.loadbalancer,
  ]

  application_credential_id     = var.application_credential_id
  application_credential_secret = var.application_credential_secret
  domain_id                     = var.domain_id
  project_id                    = var.project_id
  auth_url                      = var.auth_url
  region                        = var.region
  availability_zone             = var.availability_zone

  name = var.name

  network_id = module.network_loadbalancer.id

  kubernetes_version       = var.kubernetes_version
  openstack_chart_versions = var.openstack_chart_versions
  image_name               = var.image_name
  cluster_cidr             = var.cluster_cidr
  service_cidr             = var.service_cidr

  global_registry_auth_secret = var.global_registry_auth_secret
  gcsa_username               = var.gcsa_username
  gcsa_password               = var.gcsa_password

  control_pool = {
    name    = "system"
    flavour = var.node_pools.system.flavour
    count   = var.node_pools.system.count
    labels = {
      "node.ssc-spc.gc.ca/use"     = "general"
      "node.ssc-spc.gc.ca/purpose" = "system"
    }
    taints          = []
    security_groups = var.node_pools.system.security_groups
    volume_type     = var.node_pools.system.volume_type
    volume_size     = var.node_pools.system.volume_size
    roles           = ["etcd", "control"]
    network_id      = module.network_system.id
  }

  worker_pool = {
    name    = "general"
    flavour = var.node_pools.general.flavour
    count   = var.node_pools.general.count
    labels = {
      "node.ssc-spc.gc.ca/use"     = "general"
      "node.ssc-spc.gc.ca/purpose" = "general"
    }
    taints          = []
    security_groups = var.node_pools.general.security_groups
    volume_type     = var.node_pools.general.volume_type
    volume_size     = var.node_pools.general.volume_size
    roles           = ["worker"]
    network_id      = module.network_general.id
  }

  additional_pools = [{
    name    = "gateway"
    flavour = var.node_pools.gateway.flavour
    count   = var.node_pools.gateway.count
    labels = {
      "node.ssc-spc.gc.ca/use"     = "general"
      "node.ssc-spc.gc.ca/purpose" = "gateway"
    }
    taints = [
      {
        key    = "node.ssc-spc.gc.ca/purpose"
        value  = "gateway"
        effect = "NoSchedule"
      }
    ]
    security_groups = var.node_pools.gateway.security_groups
    volume_type     = var.node_pools.gateway.volume_type
    volume_size     = var.node_pools.gateway.volume_size
    roles           = ["worker"]
    network_id      = module.network_gateway.id
  }]
}

# Provides a Rancher v2 Cluster Role Template Binding resource.
#
# https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cluster_role_template_binding
#
resource "rancher2_cluster_role_template_binding" "cluster_operator" {
  for_each         = toset(var.cluster_operators)
  name             = "crtb-cluster-owner-${each.key}"
  cluster_id       = module.infrastructure.cluster_v1_id
  role_template_id = "cluster-owner"
  user_id          = each.key
}
