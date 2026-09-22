# Changelog

All notable changes to this module are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Releases are
cut automatically on merge to `main` from the release label applied to the pull request — see
[.github/workflows/trigger_release.yml](.github/workflows/trigger_release.yml).

## [v1.0.0] - 2026-09-21

Consolidation release. The module now lives at
`gccloudone-aurora-iac/terraform-kubernetes-private-cloud-environment`, so callers must
update their `source` URL. Terraform resource addresses are unchanged and no state migration
is required.

### Changed

- Vendored the downstream infrastructure modules into [modules/](modules/) instead of
  referencing them as separate `git::https://` repositories, both previously unpinned at
  `?ref=main`. See [modules/VENDOR.md](modules/VENDOR.md) for the upstream repository and
  commit each came from. No module stays remote — there is no naming-convention module in
  the private-cloud stack.
- Aligned the networking and subnets, the node pools, and the Terraform naming conventions.
- Uniform comment style across every `.tf` file, and a doc comment on every `resource`,
  `module` and `data` block.
- `router_name` moved to the networking section of [variables.tf](variables.tf), where it is
  actually used.
- The `## History` table in [README.md](README.md) has been folded into this file, which is
  now the single release history.

### Added

- `terraform fmt`, `terraform validate` and a terraform-docs drift check in CI.
- [examples/standard.tf](examples/standard.tf) and
  [examples/terraform.tfvars.example](examples/terraform.tfvars.example); the README had
  linked to `examples/` since the initial commit, but the directory did not exist.
- A generated `README.md` for every vendored module.
- [AGENTS.md](AGENTS.md) and [modules/VENDOR.md](modules/VENDOR.md).

### Fixed

- `router_name` was described as the router to attach to "the Vault cluster subnet"; nothing
  in this module is Vault.
- `kubernetes_version` is an RKE2 version string as Rancher reports it, for example
  `v1.34.1+rke2r1`, not a bare Kubernetes version.
- Typos and missing descriptions across variables and outputs, and an explicit `type` on
  every variable that previously rendered as `any`.
- A misaligned `### Rancher Resources ###` banner in
  `modules/kubernetes-cluster/variables.tf`.
- `.gitattributes` used the invalid line-ending value `eol=tf`; corrected to `eol=lf`.

[v1.0.0]: https://github.com/gccloudone-aurora-iac/terraform-kubernetes-private-cloud-environment/releases/tag/v1.0.0
