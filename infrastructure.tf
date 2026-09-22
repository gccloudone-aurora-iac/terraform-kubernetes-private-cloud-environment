# Deploys Rancher Kubernetes Cluster and its related infrastructure.
#
# ./modules/kubernetes-cluster
#
module "infrastructure" {
  source = "./modules/kubernetes-cluster"

  openstack_application_credential_id     = var.openstack_application_credential_id
  openstack_application_credential_secret = var.openstack_application_credential_secret
  openstack_domain_id                     = var.openstack_domain_id
  openstack_project_id                    = var.openstack_project_id
  openstack_auth_url                      = var.openstack_auth_url
  openstack_region                        = var.openstack_region

  name = var.cluster_name

  loadbalancer_network_id = module.network_loadbalancer.id

  kubernetes_version = var.kubernetes_version

  control_pool = {
    name    = "system"
    flavour = "g4v-16"
    count   = 1
    labels = {
      "node.ssc-spc.gc.ca/use"     = "general"
      "node.ssc-spc.gc.ca/purpose" = "system"
    }
    taints          = []
    security_groups = ["default"]
    volume_type     = "performance"
    volume_size     = 60
    roles           = ["etcd", "control"]
    network_id      = module.network_system.id
  }

  worker_pool = {
    name    = "general"
    flavour = "g4v-16"
    count   = 1
    labels = {
      "node.ssc-spc.gc.ca/use"     = "general"
      "node.ssc-spc.gc.ca/purpose" = "general"
    }
    taints          = []
    security_groups = ["default"]
    volume_type     = "performance"
    volume_size     = 60
    roles           = ["worker"]
    network_id      = module.network_general.id
  }

  additional_pools = [{
    name    = "gateway"
    flavour = "g4v-16"
    count   = 1
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
    security_groups = ["default"]
    volume_type     = "performance"
    volume_size     = 60
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
