# terraform-private-cloud-kubernetes-cluster

This module deploys a Kubernetes cluster via Rancher in GC Private Cloud.

The `openstack_chart_versions` input pins both bootstrap Helm charts to `2.37.1`
by default. See [Bootstrap Chart Versions](../../README.md#bootstrap-chart-versions)
for the override syntax and compatibility requirements. When using this submodule
directly, ensure its node networks, subnets, and router interfaces are ready first.

<!-- BEGIN_TF_DOCS -->
## 📋 Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | >= 15.1.2 |

## 🔌 Providers

| Name | Version |
|------|---------|
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | >= 15.1.2 |

## 🧩 Modules

No modules.

## 🗂️ Resources

| Name | Type |
|------|------|
| [rancher2_cloud_credential.this](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cloud_credential) | resource |
| [rancher2_cluster_v2.this](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cluster_v2) | resource |
| [rancher2_machine_config_v2.this](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/machine_config_v2) | resource |

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_pools"></a> [additional\_pools](#input\_additional\_pools) | List of pools for the cluster. | <pre>list(object({<br/>    name    = string<br/>    roles   = optional(list(string), ["worker"])<br/>    flavour = optional(string, "g4v-16")<br/>    count   = optional(number, 1)<br/>    labels  = optional(map(string))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = optional(string, "NoExecute")<br/>    })), [])<br/>    security_groups = optional(list(string), ["default"])<br/>    volume_type     = optional(string, "performance")<br/>    volume_size     = optional(number, 60)<br/>    image_name      = optional(string)<br/>    user_data       = optional(string)<br/>    network_id      = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_application_credential_id"></a> [application\_credential\_id](#input\_application\_credential\_id) | Application Credential ID for authentication with OpenStack. | `string` | n/a | yes |
| <a name="input_application_credential_secret"></a> [application\_credential\_secret](#input\_application\_credential\_secret) | Application Credential Secret for authentication with OpenStack. | `string` | n/a | yes |
| <a name="input_auth_url"></a> [auth\_url](#input\_auth\_url) | OpenStack Authentication URL | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | OpenStack Availability Zone where to deploy the cluster. | `string` | `null` | no |
| <a name="input_cluster_cidr"></a> [cluster\_cidr](#input\_cluster\_cidr) | CIDR of the cluster. | `list(string)` | <pre>[<br/>  "192.168.0.0/16"<br/>]</pre> | no |
| <a name="input_control_pool"></a> [control\_pool](#input\_control\_pool) | Configuration for the control pool. | <pre>object({<br/>    name    = optional(string, "control")<br/>    flavour = optional(string, "g4v-16")<br/>    count   = optional(number, 1)<br/>    labels  = optional(map(string))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = optional(string, "NoExecute")<br/>    })), [])<br/>    security_groups = optional(list(string), ["default"])<br/>    volume_type     = optional(string, "performance")<br/>    volume_size     = optional(number, 60)<br/>    roles           = optional(list(string), ["etcd", "control"])<br/>    image_name      = optional(string)<br/>    user_data       = optional(string)<br/>    network_id      = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | Domain ID of the OpenStack tenant where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_gcsa_password"></a> [gcsa\_password](#input\_gcsa\_password) | Password for the GC Secure Artifacts repositories. | `string` | n/a | yes |
| <a name="input_gcsa_username"></a> [gcsa\_username](#input\_gcsa\_username) | Username for the GC Secure Artifacts repositories. | `string` | n/a | yes |
| <a name="input_global_registry"></a> [global\_registry](#input\_global\_registry) | Global registry for system resources. | `string` | `"artifacts-artefacts.devops.cloud-nuage.canada.ca"` | no |
| <a name="input_global_registry_auth_secret"></a> [global\_registry\_auth\_secret](#input\_global\_registry\_auth\_secret) | Secret name containing global registry authentication for system resources. | `string` | `"gcsa"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the image for the nodes. | `string` | `"debian-13-trixie"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Version of Kubernetes to install. | `string` | `"v1.36.3+rke2r1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the cluster. | `string` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Network ID of the OpenStack network where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin to use for the cluster. | `string` | `"cilium"` | no |
| <a name="input_openstack_chart_versions"></a> [openstack\_chart\_versions](#input\_openstack\_chart\_versions) | Exact Helm chart versions for the OpenStack cloud controller manager and Cinder CSI driver. | <pre>object({<br/>    cloud_controller_manager = string<br/>    cinder_csi               = string<br/>  })</pre> | <pre>{<br/>  "cinder_csi": "2.37.1",<br/>  "cloud_controller_manager": "2.37.1"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID of the OpenStack project where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | OpenStack region where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Cluster service CIDRs. | `list(string)` | <pre>[<br/>  "172.16.0.0/20"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to the OpenStack resources. | `map(string)` | `{}` | no |
| <a name="input_worker_pool"></a> [worker\_pool](#input\_worker\_pool) | Configuration for the worker pool. | <pre>object({<br/>    name    = optional(string, "worker")<br/>    flavour = optional(string, "g4v-16")<br/>    count   = optional(number, 1)<br/>    labels  = optional(map(string))<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = optional(string, "NoExecute")<br/>    })), [])<br/>    security_groups = optional(list(string), ["default"])<br/>    volume_type     = optional(string, "performance")<br/>    volume_size     = optional(number, 60)<br/>    roles           = optional(list(string), ["worker"])<br/>    image_name      = optional(string)<br/>    user_data       = optional(string)<br/>    network_id      = optional(string)<br/>  })</pre> | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_v1_id"></a> [cluster\_v1\_id](#output\_cluster\_v1\_id) | The v1 compatible ID of the new Rancher cluster. |
<!-- END_TF_DOCS -->
