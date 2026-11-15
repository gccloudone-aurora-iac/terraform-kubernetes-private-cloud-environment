# Changelog

All notable changes to this module are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases are
cut automatically on merge to `main` from the release label applied to the pull request — see
[.github/workflows/trigger_release.yml](.github/workflows/trigger_release.yml).

## [Unreleased]

### Breaking

- Removed the unused input `network_name` (and its data source). Callers must stop passing it.
- Cilium always runs in kube-proxy replacement mode (kube-proxy disabled). Existing clusters
  switch on their next apply, which restarts Cilium on every node.
- Cilium uses netkit interfaces. On an existing node, cilium-agent won't start until pods
  still using veth are deleted or the node is replaced.
- Cloud-init changes (NTP, inotify, graceful shutdown, `gcsa.conf` mode) replace every node on
  the next apply.

### Added

- Optional GPU pool (`node_pools.gpu.enabled`, default flavour `p36v-100-gpu`, 200 GB disk),
  tainted `node.ssc-spc.gc.ca/purpose=gpu:NoSchedule`, using the GPU cloud-init.
- NVIDIA GPU Operator, replacing the device plugin. Installed only when a GPU pool exists;
  version set by `gpu_operator_version` (default `v26.7.2`).
- `nvidia_driver_version` (default `620.70.06-1`): pins the NVIDIA driver on GPU nodes.
- GPU nodes run with persistence mode on (`nvidia-persistenced`).
- Registry mirrors for `nvcr.io` and `ghcr.io` through GC Secure Artifacts.
- Outputs `cluster_v1_id` (root) and `machine_pools` (`kubernetes-cluster`).
- Every node: graceful shutdown (60 s, 20 s for critical pods), both GC NTP servers, and
  `fs.inotify.max_user_instances = 8192`.
- Cilium: eBPF host routing (CNI chaining off), eBPF masquerading, bandwidth manager with BBR.

### Changed

- `gcsa.conf` is `0600` on every node; GPU keyrings are `0644`.
- `rancher2` provider constrained to `>= 15.1.2, < 16.0.0`.

### Fixed

- GPU pools roll delete-first, so a single-GPU pool can be replaced.
- GPU cloud-init starts with `#cloud-config`.

## [v1.0.0] - 2026-09-21

Consolidation release. The module now lives at
`gccloudone-aurora-iac/terraform-kubernetes-private-cloud-environment`, so callers must
update their `source` URL. Terraform resource addresses are unchanged and no state migration
is required.

### Changed

- `required_version` is `>= 1.9.0, < 2.0.0` in the root, every module and every example.
  CI pins Terraform 1.12.2.
- CI is now `terraform_checks.yml` (fmt, validate, examples, terraform-docs drift) and
  `trigger_release.yml` (release cut from the PR label).
- `.terraform-docs.yml` sets emoji section headings; generated tables are otherwise
  byte-identical to the default output. READMEs regenerated.
- README badges.
- Vendored both infrastructure modules into [modules/](modules/); they were unpinned
  `git::https://` references. No module resolves over the network.
- Aligned the networking and subnets, the node pools, and the Terraform naming conventions.
- Uniform comment style across every `.tf` file, and a doc comment on every `resource`,
  `module` and `data` block.
- `router_name` moved to the networking section of [variables.tf](variables.tf), where it is
  actually used.

### Added

- [examples/standard.tf](examples/standard.tf) and
  [examples/terraform.tfvars.example](examples/terraform.tfvars.example); the README had
  linked to `examples/` since the initial commit, but the directory did not exist.
- A generated `README.md` for every vendored module.

### Fixed

- `kubernetes_version` is an RKE2 version string as Rancher reports it, for example
  `v1.34.1+rke2r1`, not a bare Kubernetes version.

[v1.0.0]: https://github.com/gccloudone-aurora-iac/terraform-kubernetes-private-cloud-environment/releases/tag/v1.0.0
