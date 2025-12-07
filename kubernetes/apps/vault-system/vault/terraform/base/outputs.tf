output "kubernetes_auth_path" {
  description = "The path where Kubernetes auth is mounted"
  value       = vault_auth_backend.kubernetes.path
}

output "policies_created" {
  description = "List of policies created"
  value = [
    vault_policy.readonly.name,
    vault_policy.app_default.name,
  ]
}
