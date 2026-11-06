# terraform-kubernetes-private-cloud-environment

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io/)
[![OpenStack](https://img.shields.io/badge/OpenStack-%23ED1944.svg?style=for-the-badge&logo=openstack&logoColor=white)](https://www.openstack.org/)
[![Rancher](https://img.shields.io/badge/Rancher-%230075A8.svg?style=for-the-badge&logo=rancher&logoColor=white)](https://www.rancher.com/)
[![Kubernetes](https://img.shields.io/badge/kubernetes-%23326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

This module deploys the Aurora environment in GC Private Cloud.

## 📦 Usage

See [variables.tf](variables.tf) for supported module inputs and
[terraform.tfvars.example](terraform.tfvars.example) for example values.

## Node and Network Configuration

Optional root-module inputs expose the node image, availability zone, pod and
service CIDRs, pool sizing and security groups, and registry authentication secret.
Their defaults preserve the existing configuration. For example, set these inputs
in the consuming module block, replacing the zone and security groups with values
that exist in your environment:

```hcl
availability_zone           = "your-openstack-zone"
image_name                  = "debian-13-trixie"
cluster_cidr                = ["192.168.0.0/16"]
service_cidr                = ["172.16.0.0/20"]
global_registry_auth_secret = "gcsa"

node_pools = {
	general = {
		count           = 2
		flavour         = "g4v-32"
		volume_size     = 100
		volume_type     = "performance"
		security_groups = ["cluster-nodes"]
	}
}
```

Omitted pools and attributes retain their defaults: one node per pool, `g4v-16`,
60 GiB `performance` boot volumes, and the `default` security group. Pool names,
roles, labels, taints, and network assignments remain module-managed. A null
availability zone retains the existing fallback to the region name.

Choose pod and service CIDRs that do not overlap each other or your infrastructure
networks before creating the cluster. Changing them on an existing cluster is
disruptive. Image, availability-zone, and boot-volume changes can replace nodes;
review the plan before applying. The registry authentication secret must already
exist in Rancher.

## Bootstrap Chart Versions

The OpenStack cloud controller manager and Cinder CSI Helm charts are pinned to
`2.37.1` by default. Override the module input to select exact versions available
in the private Helm repository and compatible with your Kubernetes release:

```hcl
openstack_chart_versions = {
	cloud_controller_manager = "2.37.1"
	cinder_csi               = "2.37.1"
}
```

Version ranges are not accepted. Cluster provisioning waits for all four subnet
router interfaces before creating nodes.

<!-- BEGIN_TF_DOCS -->
## 📋 Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_openstack"></a> [openstack](#requirement\_openstack) | >= 3.0.0, < 4.0.0 |
| <a name="requirement_rancher2"></a> [rancher2](#requirement\_rancher2) | >= 15.1.2 |

## 🔌 Providers

| Name | Version |
|------|---------|
| <a name="provider_openstack"></a> [openstack](#provider\_openstack) | 3.4.0 |
| <a name="provider_rancher2"></a> [rancher2](#provider\_rancher2) | 15.1.2 |

## 🧩 Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_infrastructure"></a> [infrastructure](#module\_infrastructure) | ./modules/kubernetes-cluster | n/a |
| <a name="module_network_gateway"></a> [network\_gateway](#module\_network\_gateway) | ./modules/openstack-network | n/a |
| <a name="module_network_general"></a> [network\_general](#module\_network\_general) | ./modules/openstack-network | n/a |
| <a name="module_network_loadbalancer"></a> [network\_loadbalancer](#module\_network\_loadbalancer) | ./modules/openstack-network | n/a |
| <a name="module_network_system"></a> [network\_system](#module\_network\_system) | ./modules/openstack-network | n/a |

## 🗂️ Resources

| Name | Type |
|------|------|
| [openstack_networking_router_interface_v2.gateway](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2) | resource |
| [openstack_networking_router_interface_v2.general](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2) | resource |
| [openstack_networking_router_interface_v2.loadbalancer](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2) | resource |
| [openstack_networking_router_interface_v2.system](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_router_interface_v2) | resource |
| [rancher2_cluster_role_template_binding.cluster_operator](https://registry.terraform.io/providers/rancher/rancher2/latest/docs/resources/cluster_role_template_binding) | resource |
| [openstack_networking_network_v2.external](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_network_v2) | data source |
| [openstack_networking_router_v2.default](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/data-sources/networking_router_v2) | data source |

## 📥 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_credential_id"></a> [application\_credential\_id](#input\_application\_credential\_id) | Application Credential ID used by Rancher to provision on OpenStack. | `string` | n/a | yes |
| <a name="input_application_credential_secret"></a> [application\_credential\_secret](#input\_application\_credential\_secret) | Application Credential Secret used by Rancher to provision on OpenStack. | `string` | n/a | yes |
| <a name="input_auth_url"></a> [auth\_url](#input\_auth\_url) | OpenStack Authentication URL. | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | OpenStack availability zone for the nodes. Null preserves the existing region-name fallback. | `string` | `null` | no |
| <a name="input_cluster_cidr"></a> [cluster\_cidr](#input\_cluster\_cidr) | Pod network CIDRs. Choose non-overlapping ranges before deployment; changing an existing cluster is disruptive. | `list(string)` | <pre>[<br/>  "192.168.0.0/16"<br/>]</pre> | no |
| <a name="input_cluster_operators"></a> [cluster\_operators](#input\_cluster\_operators) | A list of Rancher user IDs to indicate the operators of the cluster. | `list(string)` | n/a | yes |
| <a name="input_dns_nameservers"></a> [dns\_nameservers](#input\_dns\_nameservers) | A list of DNS servers to advertise to clients on the network. | `list(string)` | n/a | yes |
| <a name="input_domain_id"></a> [domain\_id](#input\_domain\_id) | Domain ID of the OpenStack tenant where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_gcsa_password"></a> [gcsa\_password](#input\_gcsa\_password) | Password for the GC Secure Artifacts repositories. | `string` | n/a | yes |
| <a name="input_gcsa_username"></a> [gcsa\_username](#input\_gcsa\_username) | Username for the GC Secure Artifacts repositories. | `string` | n/a | yes |
| <a name="input_global_registry_auth_secret"></a> [global\_registry\_auth\_secret](#input\_global\_registry\_auth\_secret) | Name of the pre-existing Rancher registry authentication secret for system images. | `string` | `"gcsa"` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the OpenStack image used for cluster nodes. | `string` | `"debian-13-trixie"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The RKE2 version used by the control plane and the default version for the agent nodes, as Rancher reports it (e.g. v1.34.1+rke2r1). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Rancher Cluster. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the pre-existing OpenStack network to attach. | `string` | n/a | yes |
| <a name="input_network_prefixes"></a> [network\_prefixes](#input\_network\_prefixes) | Map of network zone names to their corresponding IPv4 and IPv6 prefixes. All four zones (system, general, gateway, loadbalancer) are required. | <pre>map(object({<br/>    prefixes_v4 = list(string)<br/>    prefixes_v6 = list(string)<br/>  }))</pre> | <pre>{<br/>  "gateway": {<br/>    "prefixes_v4": [<br/>      "10.0.4.0/24"<br/>    ],<br/>    "prefixes_v6": []<br/>  },<br/>  "general": {<br/>    "prefixes_v4": [<br/>      "10.0.2.0/24"<br/>    ],<br/>    "prefixes_v6": []<br/>  },<br/>  "loadbalancer": {<br/>    "prefixes_v4": [<br/>      "10.0.6.0/24"<br/>    ],<br/>    "prefixes_v6": []<br/>  },<br/>  "system": {<br/>    "prefixes_v4": [<br/>      "10.0.1.0/24"<br/>    ],<br/>    "prefixes_v6": []<br/>  }<br/>}</pre> | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Sizing and security groups for each node pool. Names, roles, labels, taints, and network assignments remain module-managed. | <pre>object({<br/>    system = optional(object({<br/>      count           = optional(number, 1)<br/>      flavour         = optional(string, "g4v-16")<br/>      volume_size     = optional(number, 60)<br/>      volume_type     = optional(string, "performance")<br/>      security_groups = optional(list(string), ["default"])<br/>    }), {})<br/>    general = optional(object({<br/>      count           = optional(number, 1)<br/>      flavour         = optional(string, "g4v-16")<br/>      volume_size     = optional(number, 60)<br/>      volume_type     = optional(string, "performance")<br/>      security_groups = optional(list(string), ["default"])<br/>    }), {})<br/>    gateway = optional(object({<br/>      count           = optional(number, 1)<br/>      flavour         = optional(string, "g4v-16")<br/>      volume_size     = optional(number, 60)<br/>      volume_type     = optional(string, "performance")<br/>      security_groups = optional(list(string), ["default"])<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_openstack_chart_versions"></a> [openstack\_chart\_versions](#input\_openstack\_chart\_versions) | Exact Helm chart versions for the OpenStack cloud controller manager and Cinder CSI driver. | <pre>object({<br/>    cloud_controller_manager = string<br/>    cinder_csi               = string<br/>  })</pre> | <pre>{<br/>  "cinder_csi": "2.37.1",<br/>  "cloud_controller_manager": "2.37.1"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID of the OpenStack project where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | OpenStack region where to deploy the cluster. | `string` | n/a | yes |
| <a name="input_router_name"></a> [router\_name](#input\_router\_name) | The name of the pre-existing OpenStack router to attach. | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Service network CIDRs. Choose non-overlapping ranges before deployment; changing an existing cluster is disruptive. | `list(string)` | <pre>[<br/>  "172.16.0.0/20"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to the OpenStack resources. | `map(string)` | `{}` | no |

## 📤 Outputs

No outputs.
<!-- END_TF_DOCS -->

## 📜 History

See [CHANGELOG.md](CHANGELOG.md) for the full release history.
