# Provides a Rancher v2 Cloud Credential resource.
#
# https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cloud_credential
#
resource "rancher2_cloud_credential" "this" {
  name = var.name
  openstack_credential_config {
    password = ""
  }
}

# Provides a Rancher v2 Machine config v2 resource.
#
# https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/machine_config_v2
#
resource "rancher2_machine_config_v2" "this" {
  for_each = { for pool in local.pools : pool.name => pool }

  generate_name = each.key

  openstack_config {
    auth_url                      = var.auth_url
    application_credential_id     = var.application_credential_id
    application_credential_secret = var.application_credential_secret
    region                        = var.region
    availability_zone             = coalesce(var.availability_zone, var.region)
    domain_id                     = var.domain_id
    tenant_domain_id              = var.domain_id
    tenant_id                     = var.project_id
    flavor_name                   = each.value.flavour
    image_name                    = coalesce(each.value.image_name, var.image_name)
    net_id                        = coalesce(each.value.network_id, var.network_id)
    sec_groups                    = join(",", each.value.security_groups)
    ssh_user                      = "debian"
    user_data_file = coalesce(each.value.user_data, templatefile("${path.module}/config/cloud-init.yaml", {
      gcsa_username = var.gcsa_username,
      gcsa_password = var.gcsa_password,
    }))
    boot_from_volume = true
    volume_type      = each.value.volume_type
    volume_size      = each.value.volume_size
    user_domain_name = "Default"
  }
}

# Provides a Rancher v2 Cluster v2 resource.
#
# https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cluster_v2
#
resource "rancher2_cluster_v2" "this" {
  name               = var.name
  kubernetes_version = var.kubernetes_version

  enable_network_policy = true

  rke_config {
    registries {
      configs {
        hostname                = var.global_registry
        auth_config_secret_name = var.global_registry_auth_secret
      }

      mirrors {
        hostname  = "docker.io"
        endpoints = ["https://${var.global_registry}"]
        rewrites = {
          "(.*)" : "docker-docker-remote/$1"
        }
      }

      mirrors {
        hostname  = "quay.io"
        endpoints = ["https://${var.global_registry}"]
        rewrites = {
          "(.*)" : "docker-quay-remote/$1"
        }
      }

      mirrors {
        hostname  = "registry.k8s.io"
        endpoints = ["https://${var.global_registry}"]
        rewrites = {
          "(.*)" : "ssc-pcc-docker-k8s-remote/$1"
        }
      }
    }

    machine_global_config = <<EOF
cni: "${var.network_plugin}"
cluster-cidr: ${join(",", var.cluster_cidr)}
service-cidr: ${join(",", var.service_cidr)}
disable:
  - rke2-ingress-nginx
  - rke2-traefik-crd
  - rke2-traefik
cloud-provider-name: external
disable-cloud-controller: true
EOF

    chart_values = yamlencode(merge(
      yamldecode(templatefile("${path.module}/config/rancher.yaml.tftpl", {
        global_registry = var.global_registry
      })),
    yamldecode(templatefile("${path.module}/config/cni/${var.network_plugin}.yaml.tftpl", {}))))

    dynamic "machine_pools" {
      for_each = local.pools

      content {
        name                         = machine_pools.value.name
        cloud_credential_secret_name = rancher2_cloud_credential.this.id
        control_plane_role           = contains(machine_pools.value.roles, "control")
        etcd_role                    = contains(machine_pools.value.roles, "etcd")
        worker_role                  = contains(machine_pools.value.roles, "worker")
        quantity                     = machine_pools.value.count
        drain_before_delete          = true
        machine_labels               = machine_pools.value.labels
        dynamic "taints" {
          for_each = machine_pools.value.taints

          content {
            key    = taints.value.key
            value  = taints.value.value
            effect = taints.value.effect
          }
        }

        machine_config {
          kind = rancher2_machine_config_v2.this[machine_pools.value.name].kind
          name = rancher2_machine_config_v2.this[machine_pools.value.name].name
        }
      }
    }

    additional_manifest = templatefile("${path.module}/config/manifest.yaml.tftpl", {
      auth_url                      = var.auth_url,
      region                        = var.region,
      domain_id                     = var.domain_id,
      project_id                    = var.project_id,
      application_credential_id     = var.application_credential_id,
      application_credential_secret = var.application_credential_secret,
      cluster_cidr                  = var.cluster_cidr,
      network_id                    = var.network_id,
      gcsa_username                 = var.gcsa_username,
      gcsa_password                 = var.gcsa_password,
      openstack_chart_versions      = var.openstack_chart_versions,
    })
  }

  cluster_agent_deployment_customization {
    append_tolerations {
      key      = "node.kubernetes.io/not-ready"
      operator = "Exists"
      effect   = "NoSchedule"
    }
  }
}
