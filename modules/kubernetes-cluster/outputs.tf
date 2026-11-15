output "cluster_v1_id" {
  description = "The v1 compatible ID of the new Rancher cluster."
  value       = rancher2_cluster_v2.this.cluster_v1_id
}

output "machine_pools" {
  description = "The machine pools of the cluster, keyed by name, with their node count and whether they use the GPU cloud-init."
  value = {
    for pool in local.pools : pool.name => {
      count = pool.count
      gpu   = pool.gpu
    }
  }
}
