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
