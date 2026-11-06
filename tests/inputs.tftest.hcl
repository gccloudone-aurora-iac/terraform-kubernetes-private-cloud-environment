mock_provider "openstack" {}
mock_provider "rancher2" {}

variables {
  application_credential_id     = "test-id"
  application_credential_secret = "test-secret"
  auth_url                      = "https://identity.example.test/v3"
  domain_id                     = "test-domain"
  project_id                    = "test-project"
  region                        = "test-region"
  name                          = "test-cluster"
  kubernetes_version            = "v1.36.3+rke2r1"
  cluster_operators             = []
  network_name                  = "test-network"
  router_name                   = "test-router"
  dns_nameservers               = ["192.0.2.53"]
  gcsa_username                 = "test-user"
  gcsa_password                 = "test-password"
}

run "preserve_defaults" {
  command = plan

  assert {
    condition = alltrue([
      for pool in values(var.node_pools) :
      pool.count == 1 && pool.flavour == "g4v-16" &&
      pool.volume_size == 60 && pool.volume_type == "performance" &&
      pool.security_groups == tolist(["default"])
    ])
    error_message = "Default pool sizing and security groups must remain unchanged."
  }

  assert {
    condition = (
      var.availability_zone == null &&
      var.image_name == "debian-13-trixie" &&
      var.cluster_cidr == tolist(["192.168.0.0/16"]) &&
      var.service_cidr == tolist(["172.16.0.0/20"]) &&
      var.global_registry_auth_secret == "gcsa"
    )
    error_message = "New root inputs must preserve the previous submodule defaults."
  }
}

run "override_environment_settings" {
  command = plan

  variables {
    availability_zone           = "test-zone"
    image_name                  = "tested-image"
    cluster_cidr                = ["10.244.0.0/16"]
    service_cidr                = ["10.96.0.0/12"]
    global_registry_auth_secret = "environment-registry"
    node_pools = {
      general = {
        count           = 3
        flavour         = "g4v-32"
        volume_size     = 100
        volume_type     = "capacity"
        security_groups = ["cluster-nodes"]
      }
    }
  }

  assert {
    condition = (
      var.node_pools.general.count == 3 &&
      var.node_pools.general.flavour == "g4v-32" &&
      var.node_pools.general.volume_size == 100 &&
      var.node_pools.general.volume_type == "capacity" &&
      var.node_pools.general.security_groups == tolist(["cluster-nodes"]) &&
      var.node_pools.system.count == 1 && var.node_pools.gateway.count == 1 &&
      var.node_pools.system.security_groups == tolist(["default"])
    )
    error_message = "A partial pool override must preserve defaults for the other pools."
  }
}

run "reject_missing_system_node" {
  command = plan

  variables {
    node_pools = { system = { count = 0 } }
  }

  expect_failures = [var.node_pools]
}

run "reject_fractional_node_count" {
  command = plan

  variables {
    node_pools = { general = { count = 1.5 } }
  }

  expect_failures = [var.node_pools]
}

run "reject_invalid_volume_size" {
  command = plan

  variables {
    node_pools = { gateway = { volume_size = 0 } }
  }

  expect_failures = [var.node_pools]
}

run "reject_invalid_pod_cidr" {
  command = plan

  variables {
    cluster_cidr = ["not-a-cidr"]
  }

  expect_failures = [var.cluster_cidr]
}

run "reject_empty_service_cidrs" {
  command = plan

  variables {
    service_cidr = []
  }

  expect_failures = [var.service_cidr]
}
